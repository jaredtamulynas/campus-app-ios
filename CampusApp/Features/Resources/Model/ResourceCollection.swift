//
//  ResourceCollection.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/30/25.
//

import Foundation

/// A collection of resources organized by category
struct ResourceCollection: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String?
    let resources: [Resource]
    let visibility: PerspectiveVisibility
    let order: Int?
    
    /// Get resources visible for the given perspective
    func visibleResources(for perspective: PerspectiveType) -> [Resource] {
        guard visibility.isVisible(for: perspective) else {
            return []
        }
        
        return resources.filter { $0.isVisible(for: perspective) }
    }
}

/// Container for all resources
struct ResourcesData: Codable {
    let resources: [Resource]
    let lastUpdated: String?
    
    /// Get all resources visible for the given perspective
    func visibleResources(for perspective: PerspectiveType) -> [Resource] {
        return resources.filter { $0.isVisible(for: perspective) }
    }
}
