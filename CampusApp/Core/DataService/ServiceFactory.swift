//
//  ServiceFactory.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import Foundation

// MARK: - Service Environment

/// Defines the data source environment for the app
enum ServiceEnvironment: String, CaseIterable {
    case local      // Use only local JSON files (development/testing)
    case cloud      // Use cloud with local fallback (production)
    case cloudOnly  // Use cloud only, fail if unavailable
    
    static var current: ServiceEnvironment {
        // Check for override in environment (useful for testing)
        if let override = ProcessInfo.processInfo.environment["SERVICE_ENV"],
           let env = ServiceEnvironment(rawValue: override) {
            return env
        }
        
        #if DEBUG
        return .local  // Development: fast iteration with local JSON
        #else
        return .cloud  // Production: cloud with local fallback
        #endif
    }
}

// MARK: - Service Configuration

/// Configuration for a specific data service
struct ServiceConfiguration {
    let localFilename: String
    let cloudURL: URL?
    let cacheKey: String
    let cacheExpiration: TimeInterval
    
    init(
        localFilename: String,
        cloudURL: URL? = nil,
        cacheKey: String? = nil,
        cacheExpiration: TimeInterval = 3600
    ) {
        self.localFilename = localFilename
        self.cloudURL = cloudURL
        self.cacheKey = cacheKey ?? localFilename.replacingOccurrences(of: ".json", with: "")
        self.cacheExpiration = cacheExpiration
    }
    
    init(
        localFilename: String,
        cloudURLString: String?,
        cacheKey: String? = nil,
        cacheExpiration: TimeInterval = 3600
    ) {
        self.localFilename = localFilename
        self.cloudURL = cloudURLString.flatMap { URL(string: $0) }
        self.cacheKey = cacheKey ?? localFilename.replacingOccurrences(of: ".json", with: "")
        self.cacheExpiration = cacheExpiration
    }
}

// MARK: - Service Factory Protocol

/// Protocol for creating data services
/// Allows for different factory implementations (e.g., mock factory for testing)
protocol ServiceFactoryProtocol {
    func makeService<T: Decodable>(for configuration: ServiceConfiguration) -> GenericDataService<T>
}

// MARK: - Default Service Factory

/// Factory for creating data services based on the current environment
final class ServiceFactory: ServiceFactoryProtocol {
    static let shared = ServiceFactory()
    
    private let environment: ServiceEnvironment
    private let bundle: Bundle
    private let cache: DataCache
    
    init(
        environment: ServiceEnvironment = .current,
        bundle: Bundle = .main,
        cache: DataCache = FileDataCache()
    ) {
        self.environment = environment
        self.bundle = bundle
        self.cache = cache
    }
    
    func makeService<T: Decodable>(for configuration: ServiceConfiguration) -> GenericDataService<T> {
        let dataSource = makeDataSource(for: configuration)
        return GenericDataService(dataSource: dataSource)
    }
    
    private func makeDataSource(for configuration: ServiceConfiguration) -> DataSource {
        switch environment {
        case .local:
            return LocalBundleDataSource(filename: configuration.localFilename, bundle: bundle)
            
        case .cloud:
            guard let cloudURL = configuration.cloudURL else {
                // Fall back to local if no cloud URL configured
                return LocalBundleDataSource(filename: configuration.localFilename, bundle: bundle)
            }
            
            let cloudSource = CloudDataSource(url: cloudURL)
            let localSource = LocalBundleDataSource(filename: configuration.localFilename, bundle: bundle)
            let cachedCloud = CachedDataSource(
                primarySource: cloudSource,
                cacheKey: configuration.cacheKey,
                cacheExpiration: configuration.cacheExpiration,
                cache: cache
            )
            
            return FallbackDataSource(primary: cachedCloud, fallback: localSource)
            
        case .cloudOnly:
            guard let cloudURL = configuration.cloudURL else {
                fatalError("Cloud URL required for cloudOnly environment")
            }
            return CloudDataSource(url: cloudURL)
        }
    }
}

// MARK: - Mock Service Factory (for Testing)

/// Factory that always returns local data, useful for unit tests and previews
final class MockServiceFactory: ServiceFactoryProtocol {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    func makeService<T: Decodable>(for configuration: ServiceConfiguration) -> GenericDataService<T> {
        let source = LocalBundleDataSource(filename: configuration.localFilename, bundle: bundle)
        return GenericDataService(dataSource: source)
    }
}
