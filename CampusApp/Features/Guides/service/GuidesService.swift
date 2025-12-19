//
//  GuidesService.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/3/25.
//

import Foundation

// MARK: - Guides Service Protocol

/// Protocol for fetching guides
protocol GuidesServiceProtocol {
    func fetchGuides() async throws -> GuidesData
}

// MARK: - Guides Service Configuration

/// Configuration for the guides service
enum GuidesServiceConfig {
    /// Cloud storage URL for guides (uses campus ID from CampusManager)
    static var cloudURL: URL? {
        CampusManager.shared.config.cloudURL(for: "guides.json")
    }
    
    /// Default configuration using cloud with local fallback
    static var `default`: ServiceConfiguration {
        ServiceConfiguration(
            localFilename: "guides.json",
            cloudURL: cloudURL,
            cacheKey: "guides",
            cacheExpiration: 3600 // 1 hour
        )
    }
    
    /// Local-only configuration (for testing/development)
    static let local = ServiceConfiguration(
        localFilename: "guides.json",
        cloudURL: nil,
        cacheKey: "guides"
    )
    
    /// Create configuration with a custom cloud URL
    static func cloud(urlString: String) -> ServiceConfiguration {
        ServiceConfiguration(
            localFilename: "guides.json",
            cloudURLString: urlString,
            cacheKey: "guides",
            cacheExpiration: 3600
        )
    }
}

// MARK: - Guides Service Implementation

/// Service for fetching guides using the generic data service infrastructure
final class GuidesService: GuidesServiceProtocol {
    private let dataService: GenericDataService<GuidesData>
    
    init(factory: ServiceFactoryProtocol = ServiceFactory.shared) {
        self.dataService = factory.makeService(for: GuidesServiceConfig.default)
    }
    
    init(configuration: ServiceConfiguration, factory: ServiceFactoryProtocol = ServiceFactory.shared) {
        self.dataService = factory.makeService(for: configuration)
    }
    
    /// Direct initialization with a data service (useful for testing)
    init(dataService: GenericDataService<GuidesData>) {
        self.dataService = dataService
    }
    
    func fetchGuides() async throws -> GuidesData {
        try await dataService.fetch()
    }
}

// MARK: - Legacy Support (Deprecated)

/// Legacy error type - use DataServiceError instead
@available(*, deprecated, message: "Use DataServiceError instead")
typealias GuidesError = DataServiceError

/// Legacy local service - use GuidesService with local configuration instead
@available(*, deprecated, message: "Use GuidesService with ServiceFactory instead")
final class LocalGuidesService: GuidesServiceProtocol {
    private let service: GuidesService
    
    init(filename: String = "guides.json") {
        let config = ServiceConfiguration(localFilename: filename)
        self.service = GuidesService(
            configuration: config,
            factory: MockServiceFactory()
        )
    }
    
    func fetchGuides() async throws -> GuidesData {
        try await service.fetchGuides()
    }
}

/// Legacy cloud service - use GuidesService with cloud configuration instead
@available(*, deprecated, message: "Use GuidesService with ServiceFactory instead")
final class CloudGuidesService: GuidesServiceProtocol {
    private let service: GuidesService
    
    init(cloudURL: URL, fallbackService: GuidesServiceProtocol = LocalGuidesService()) {
        let config = ServiceConfiguration(
            localFilename: "guides.json",
            cloudURL: cloudURL,
            cacheKey: "guides"
        )
        self.service = GuidesService(configuration: config)
    }
    
    func fetchGuides() async throws -> GuidesData {
        try await service.fetchGuides()
    }
}
