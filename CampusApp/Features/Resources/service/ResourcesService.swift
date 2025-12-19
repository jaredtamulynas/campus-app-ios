//
//  ResourcesService.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/30/25.
//

import Foundation

// MARK: - Resources Service Protocol

/// Protocol for fetching resources
protocol ResourcesServiceProtocol {
    func fetchResources() async throws -> ResourcesData
}

// MARK: - Resources Service Configuration

/// Configuration for the resources service
enum ResourcesServiceConfig {
    /// Cloud storage URL for resources (uses campus ID from CampusManager)
    static var cloudURL: URL? {
        CampusManager.shared.config.cloudURL(for: "resources.json")
    }
    
    /// Default configuration using cloud with local fallback
    static var `default`: ServiceConfiguration {
        ServiceConfiguration(
            localFilename: "resources.json",
            cloudURL: cloudURL,
            cacheKey: "resources",
            cacheExpiration: 259200 // 3 day cache
        )
    }
    
    /// Local-only configuration (for testing/development)
    static let local = ServiceConfiguration(
        localFilename: "resources.json",
        cloudURL: nil,
        cacheKey: "resources"
    )
    
    /// Create configuration with a custom cloud URL
    static func cloud(urlString: String, cacheExpiration: TimeInterval = 259200) -> ServiceConfiguration {
        ServiceConfiguration(
            localFilename: "resources.json",
            cloudURLString: urlString,
            cacheKey: "resources",
            cacheExpiration: cacheExpiration
        )
    }
}

// MARK: - Resources Service Implementation

/// Service for fetching resources using the generic data service infrastructure
final class ResourcesService: ResourcesServiceProtocol {
    private let dataService: GenericDataService<ResourcesData>
    
    init(factory: ServiceFactoryProtocol = ServiceFactory.shared) {
        self.dataService = factory.makeService(for: ResourcesServiceConfig.default)
    }
    
    init(configuration: ServiceConfiguration, factory: ServiceFactoryProtocol = ServiceFactory.shared) {
        self.dataService = factory.makeService(for: configuration)
    }
    
    /// Direct initialization with a data service (useful for testing)
    init(dataService: GenericDataService<ResourcesData>) {
        self.dataService = dataService
    }
    
    func fetchResources() async throws -> ResourcesData {
        try await dataService.fetch()
    }
}

// MARK: - Preview Mock Service

#if DEBUG
/// Mock service for SwiftUI Previews with sample data
final class PreviewResourcesService: ResourcesServiceProtocol {
    func fetchResources() async throws -> ResourcesData {
        ResourcesData(
            resources: Resource.previewSamples,
            lastUpdated: "2025-12-04T12:00:00Z"
        )
    }
}

extension Resource {
    static let previewSamples: [Resource] = [
        Resource(
            id: "mypack-portal",
            name: "MyPack Portal",
            description: "Your central hub for student services",
            icon: "square.grid.2x2.fill",
            category: "Essentials",
            type: .externalLink,
            destination: ResourceDestination(viewIdentifier: nil, url: "https://mypack.ncsu.edu", content: nil),
            visibility: PerspectiveVisibility(perspectives: [.student, .graduate]),
            contactInfo: nil,
            featured: true
        ),
        Resource(
            id: "wolfpack-onecard",
            name: "Wolfpack OneCard",
            description: "Manage your campus ID",
            icon: "creditcard.fill",
            category: "Essentials",
            type: .externalLink,
            destination: ResourceDestination(viewIdentifier: nil, url: "https://onecard.ncsu.edu", content: nil),
            visibility: PerspectiveVisibility(perspectives: [.student, .graduate]),
            contactInfo: nil,
            featured: true
        ),
        Resource(
            id: "moodle",
            name: "Moodle (Wolfware)",
            description: "Learning management system",
            icon: "book.circle.fill",
            category: "Academics",
            type: .externalLink,
            destination: ResourceDestination(viewIdentifier: nil, url: "https://moodle.ncsu.edu", content: nil),
            visibility: PerspectiveVisibility(perspectives: [.student, .graduate]),
            contactInfo: nil,
            featured: nil
        ),
        Resource(
            id: "hill-library",
            name: "D.H. Hill Library",
            description: "Main library and research hub",
            icon: "building.columns.fill",
            category: "Libraries",
            type: .externalLink,
            destination: ResourceDestination(viewIdentifier: nil, url: "https://lib.ncsu.edu", content: nil),
            visibility: PerspectiveVisibility(perspectives: [.student, .graduate]),
            contactInfo: nil,
            featured: nil
        ),
        Resource(
            id: "wolfline",
            name: "Wolfline Bus",
            description: "Campus bus routes and tracking",
            icon: "bus.fill",
            category: "Transportation",
            type: .externalLink,
            destination: ResourceDestination(viewIdentifier: nil, url: "https://transportation.ncsu.edu", content: nil),
            visibility: PerspectiveVisibility(perspectives: [.student, .graduate]),
            contactInfo: nil,
            featured: nil
        ),
        Resource(
            id: "dining",
            name: "Dining Services",
            description: "Campus dining locations and menus",
            icon: "fork.knife",
            category: "Dining",
            type: .externalLink,
            destination: ResourceDestination(viewIdentifier: nil, url: "https://dining.ncsu.edu", content: nil),
            visibility: PerspectiveVisibility(perspectives: [.student, .graduate]),
            contactInfo: nil,
            featured: nil
        )
    ]
}
#endif
