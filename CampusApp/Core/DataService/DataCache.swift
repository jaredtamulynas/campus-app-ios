//
//  DataCache.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import Foundation

// MARK: - Data Cache Protocol

/// Protocol for caching raw data
protocol DataCache {
    /// Store data with a given key
    func store(_ data: Data, forKey key: String)
    
    /// Retrieve data for a key, optionally checking max age
    func retrieve(forKey key: String, maxAge: TimeInterval?) -> Data?
    
    /// Remove cached data for a key
    func remove(forKey key: String)
    
    /// Clear all cached data
    func clearAll()
}

extension DataCache {
    func retrieve(forKey key: String) -> Data? {
        retrieve(forKey: key, maxAge: nil)
    }
}

// MARK: - UserDefaults Data Cache

/// Simple cache implementation using UserDefaults
/// Suitable for small data sets; for larger data consider FileManager-based cache
final class UserDefaultsDataCache: DataCache {
    private let defaults: UserDefaults
    private let prefix: String
    
    init(defaults: UserDefaults = .standard, prefix: String = "cache_") {
        self.defaults = defaults
        self.prefix = prefix
    }
    
    func store(_ data: Data, forKey key: String) {
        let prefixedKey = prefix + key
        defaults.set(data, forKey: prefixedKey)
        defaults.set(Date(), forKey: prefixedKey + "_timestamp")
    }
    
    func retrieve(forKey key: String, maxAge: TimeInterval?) -> Data? {
        let prefixedKey = prefix + key
        
        guard let data = defaults.data(forKey: prefixedKey) else {
            return nil
        }
        
        // Check expiration if maxAge is specified
        if let maxAge = maxAge,
           let timestamp = defaults.object(forKey: prefixedKey + "_timestamp") as? Date {
            let age = Date().timeIntervalSince(timestamp)
            if age > maxAge {
                return nil
            }
        }
        
        return data
    }
    
    func remove(forKey key: String) {
        let prefixedKey = prefix + key
        defaults.removeObject(forKey: prefixedKey)
        defaults.removeObject(forKey: prefixedKey + "_timestamp")
    }
    
    func clearAll() {
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}

// MARK: - File-Based Data Cache

/// Cache implementation using the file system
/// Better for larger data sets
final class FileDataCache: DataCache {
    private let cacheDirectory: URL
    private let fileManager: FileManager
    
    init(
        directoryName: String = "DataCache",
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesDirectory.appendingPathComponent(directoryName)
        
        // Create directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func fileURL(forKey key: String) -> URL {
        let safeKey = key.replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent(safeKey)
    }
    
    private func timestampURL(forKey key: String) -> URL {
        let safeKey = key.replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent(safeKey + "_timestamp")
    }
    
    func store(_ data: Data, forKey key: String) {
        let fileURL = fileURL(forKey: key)
        let timestampURL = timestampURL(forKey: key)
        
        try? data.write(to: fileURL)
        try? Date().timeIntervalSince1970.description.write(to: timestampURL, atomically: true, encoding: .utf8)
    }
    
    func retrieve(forKey key: String, maxAge: TimeInterval?) -> Data? {
        let fileURL = fileURL(forKey: key)
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        // Check expiration if maxAge is specified
        if let maxAge = maxAge {
            let timestampURL = timestampURL(forKey: key)
            if let timestampString = try? String(contentsOf: timestampURL, encoding: .utf8),
               let timestamp = TimeInterval(timestampString) {
                let age = Date().timeIntervalSince1970 - timestamp
                if age > maxAge {
                    return nil
                }
            }
        }
        
        return data
    }
    
    func remove(forKey key: String) {
        try? fileManager.removeItem(at: fileURL(forKey: key))
        try? fileManager.removeItem(at: timestampURL(forKey: key))
    }
    
    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
