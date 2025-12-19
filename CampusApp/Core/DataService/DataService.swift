//
//  DataService.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import Foundation

// MARK: - Data Service Protocol

/// Generic protocol for services that fetch and decode data
/// Allows for type-safe data fetching with any Decodable type
protocol DataServiceProtocol {
    associatedtype DataType: Decodable
    
    /// Fetch and decode data from the configured source
    func fetch() async throws -> DataType
}

// MARK: - Generic Data Service Implementation

/// A generic, reusable data service that works with any Decodable type
/// This is the primary implementation used throughout the app
final class GenericDataService<T: Decodable>: DataServiceProtocol {
    typealias DataType = T
    
    private let dataSource: DataSource
    private let decoder: JSONDecoder
    
    init(
        dataSource: DataSource,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.dataSource = dataSource
        self.decoder = decoder
    }
    
    func fetch() async throws -> T {
        let data = try await dataSource.fetchData()
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw DataServiceError.decodingFailed(error)
        }
    }
}

// MARK: - Convenience Factory Methods

extension GenericDataService {
    /// Create a service that loads from a local bundle JSON file
    static func local(
        filename: String,
        bundle: Bundle = .main,
        decoder: JSONDecoder = JSONDecoder()
    ) -> GenericDataService<T> {
        let source = LocalBundleDataSource(filename: filename, bundle: bundle)
        return GenericDataService(dataSource: source, decoder: decoder)
    }
    
    /// Create a service that loads from a cloud URL with local fallback
    static func cloud(
        url: URL,
        fallbackFilename: String,
        cacheKey: String? = nil,
        cacheExpiration: TimeInterval = 3600,
        bundle: Bundle = .main,
        decoder: JSONDecoder = JSONDecoder()
    ) -> GenericDataService<T> {
        let cloudSource = CloudDataSource(url: url)
        let localSource = LocalBundleDataSource(filename: fallbackFilename, bundle: bundle)
        
        let source: DataSource
        if let cacheKey = cacheKey {
            let cachedCloud = CachedDataSource(
                primarySource: cloudSource,
                cacheKey: cacheKey,
                cacheExpiration: cacheExpiration
            )
            source = FallbackDataSource(primary: cachedCloud, fallback: localSource)
        } else {
            source = FallbackDataSource(primary: cloudSource, fallback: localSource)
        }
        
        return GenericDataService(dataSource: source, decoder: decoder)
    }
}
