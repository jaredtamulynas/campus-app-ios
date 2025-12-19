//
//  AccountService.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/14/25.
//

import Foundation

// MARK: - Account Service Protocol

/// Protocol for fetching account data
protocol AccountServiceProtocol {
    func fetchAccountData() async throws -> AccountData
}

// MARK: - Account Service Configuration

/// Configuration for the account service
enum AccountServiceConfig {
    /// Cloud storage URL for account data (uses campus ID from CampusManager)
    static var cloudURL: URL? {
        CampusManager.shared.config.cloudURL(for: "account.json")
    }
    
    /// Default configuration using cloud with local fallback
    static var `default`: ServiceConfiguration {
        ServiceConfiguration(
            localFilename: "account.json",
            cloudURL: cloudURL,
            cacheKey: "account",
            cacheExpiration: 3600 // 1 hour
        )
    }
    
    /// Local-only configuration (for testing/development)
    static let local = ServiceConfiguration(
        localFilename: "account.json",
        cloudURL: nil,
        cacheKey: "account"
    )
    
    /// Create configuration with a custom cloud URL
    static func cloud(urlString: String) -> ServiceConfiguration {
        ServiceConfiguration(
            localFilename: "account.json",
            cloudURLString: urlString,
            cacheKey: "account",
            cacheExpiration: 3600
        )
    }
}

// MARK: - Account Service Implementation

/// Service for fetching account data using the generic data service infrastructure
final class AccountService: AccountServiceProtocol {
    private let dataService: GenericDataService<AccountData>
    
    init(factory: ServiceFactoryProtocol = ServiceFactory.shared) {
        self.dataService = factory.makeService(for: AccountServiceConfig.default)
    }
    
    init(configuration: ServiceConfiguration, factory: ServiceFactoryProtocol = ServiceFactory.shared) {
        self.dataService = factory.makeService(for: configuration)
    }
    
    /// Direct initialization with a data service (useful for testing)
    init(dataService: GenericDataService<AccountData>) {
        self.dataService = dataService
    }
    
    func fetchAccountData() async throws -> AccountData {
        try await dataService.fetch()
    }
}

// MARK: - Legacy Support (Deprecated)

/// Legacy error type - use DataServiceError instead
@available(*, deprecated, message: "Use DataServiceError instead")
typealias AccountError = DataServiceError

/// Legacy local service - use AccountService with local configuration instead
@available(*, deprecated, message: "Use AccountService with ServiceFactory instead")
final class LocalAccountService: AccountServiceProtocol {
    private let service: AccountService
    
    init(filename: String = "account.json") {
        let config = ServiceConfiguration(localFilename: filename)
        self.service = AccountService(
            configuration: config,
            factory: MockServiceFactory()
        )
    }
    
    func fetchAccountData() async throws -> AccountData {
        try await service.fetchAccountData()
    }
}

/// Legacy cloud service - use AccountService with cloud configuration instead
@available(*, deprecated, message: "Use AccountService with ServiceFactory instead")
final class CloudAccountService: AccountServiceProtocol {
    private let service: AccountService
    
    init(cloudURL: URL, fallbackService: AccountServiceProtocol = LocalAccountService()) {
        let config = ServiceConfiguration(
            localFilename: "account.json",
            cloudURL: cloudURL,
            cacheKey: "account"
        )
        self.service = AccountService(configuration: config)
    }
    
    func fetchAccountData() async throws -> AccountData {
        try await service.fetchAccountData()
    }
}
