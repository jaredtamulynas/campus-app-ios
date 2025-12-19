//
//  DataServiceError.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import Foundation

/// Unified error type for all data service operations
enum DataServiceError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingFailed(Error)
    case networkError(Error)
    case invalidURL(String)
    case cacheExpired
    case noDataAvailable
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "File '\(filename)' not found"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .cacheExpired:
            return "Cached data has expired"
        case .noDataAvailable:
            return "No data available"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

