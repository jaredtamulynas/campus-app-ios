//
//  DataSource.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import Foundation
import os

// MARK: - Logging

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CampusApp", category: "DataSource")

// MARK: - Data Source Protocol

/// Protocol defining a generic data source that can fetch decodable data
/// This abstraction allows swapping between local, cloud, or cached data sources
protocol DataSource {
    /// Fetch raw data from the source
    func fetchData() async throws -> Data
}

// MARK: - Local Bundle Data Source

/// Fetches data from a JSON file in the app bundle
final class LocalBundleDataSource: DataSource {
    private let filename: String
    private let bundle: Bundle
    
    init(filename: String, bundle: Bundle = .main) {
        self.filename = filename
        self.bundle = bundle
    }
    
    func fetchData() async throws -> Data {
        // Remove .json extension if present for Bundle lookup
        let name = filename.replacingOccurrences(of: ".json", with: "")
        
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            logger.error("📁 Local file not found: \(self.filename)")
            throw DataServiceError.fileNotFound(filename)
        }
        
        let data = try Data(contentsOf: url)
        logger.info("📁 Loaded from local bundle: \(self.filename) (\(data.count) bytes)")
        return data
    }
}

// MARK: - Cloud Data Source

/// Fetches data from a remote URL (cloud storage bucket, API, etc.)
final class CloudDataSource: DataSource {
    private let url: URL
    private let session: URLSession
    private let timeoutInterval: TimeInterval
    
    init(
        url: URL,
        session: URLSession = .shared,
        timeoutInterval: TimeInterval = 30
    ) {
        self.url = url
        self.session = session
        self.timeoutInterval = timeoutInterval
    }
    
    convenience init(urlString: String, session: URLSession = .shared) throws {
        guard let url = URL(string: urlString) else {
            throw DataServiceError.invalidURL(urlString)
        }
        self.init(url: url, session: session)
    }
    
    func fetchData() async throws -> Data {
        logger.info("☁️ Fetching from cloud: \(self.url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("☁️ Cloud fetch failed: bad server response")
                throw DataServiceError.networkError(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("☁️ Cloud fetch failed: HTTP \(httpResponse.statusCode)")
                throw DataServiceError.networkError(
                    URLError(.init(rawValue: httpResponse.statusCode))
                )
            }
            
            logger.info("☁️ Cloud fetch success: \(data.count) bytes")
            return data
        } catch let error as DataServiceError {
            throw error
        } catch {
            logger.error("☁️ Cloud fetch failed: \(error.localizedDescription)")
            throw DataServiceError.networkError(error)
        }
    }
}

// MARK: - Cached Data Source

/// Wraps another data source with caching capabilities
final class CachedDataSource: DataSource {
    private let primarySource: DataSource
    private let cacheKey: String
    private let cacheExpiration: TimeInterval
    private let cache: DataCache
    
    init(
        primarySource: DataSource,
        cacheKey: String,
        cacheExpiration: TimeInterval = 3600, // 1 hour default
        cache: DataCache = UserDefaultsDataCache()
    ) {
        self.primarySource = primarySource
        self.cacheKey = cacheKey
        self.cacheExpiration = cacheExpiration
        self.cache = cache
    }
    
    func fetchData() async throws -> Data {
        // Check cache first
        if let cachedData = cache.retrieve(forKey: cacheKey, maxAge: cacheExpiration) {
            logger.info("💾 Using cached data for '\(self.cacheKey)' (\(cachedData.count) bytes)")
            return cachedData
        }
        
        logger.info("💾 Cache miss or expired for '\(self.cacheKey)', fetching fresh data...")
        
        // Fetch from primary source
        let data = try await primarySource.fetchData()
        
        // Cache the successful result
        cache.store(data, forKey: cacheKey)
        logger.info("💾 Cached fresh data for '\(self.cacheKey)'")
        
        return data
    }
    
    /// Attempt to get cached data if primary fails
    func fetchWithFallback() async throws -> Data {
        do {
            return try await fetchData()
        } catch {
            // Try to get from cache (ignoring expiration as last resort)
            if let cachedData = cache.retrieve(forKey: cacheKey) {
                logger.warning("💾 Primary failed, using stale cache for '\(self.cacheKey)'")
                return cachedData
            }
            throw error
        }
    }
}

// MARK: - Fallback Data Source

/// Tries primary source first, falls back to secondary on failure
final class FallbackDataSource: DataSource {
    private let primarySource: DataSource
    private let fallbackSource: DataSource
    
    init(primary: DataSource, fallback: DataSource) {
        self.primarySource = primary
        self.fallbackSource = fallback
    }
    
    func fetchData() async throws -> Data {
        do {
            return try await primarySource.fetchData()
        } catch {
            logger.warning("⚠️ Primary source failed, using fallback")
            return try await fallbackSource.fetchData()
        }
    }
}
