//
//  Resource.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/28/25.
//

import Foundation

struct Resource: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: String
    let type: ResourceType
    let destination: ResourceDestination
    let visibility: PerspectiveVisibility
    let contactInfo: ContactInfo?
    let featured: Bool?
    
    struct ContactInfo: Codable, Hashable {
        let phone: String?
        let email: String?
        let location: LocationInfo?
        
        struct LocationInfo: Codable, Hashable {
            let address: String
            let latitude: Double?
            let longitude: Double?
        }
    }
    
    /// Resource navigation types
    /// - `externalLink`: Opens in external browser via SwiftUI Link
    /// - `sheetCover`: Opens in SFSafariViewController as a sheet
    /// - `customView`: NavigationLink to custom in-app view
    /// - `deepLink`: Opens URL via openURL (tel:, mailto:, App Store, etc.)
    enum ResourceType: String, Codable {
        case externalLink
        case sheetCover
        case customView
        case deepLink
    }
    
    struct ResourceDestination: Codable, Hashable {
        let viewIdentifier: String?
        let url: String?
        let content: InfoContent?
        
        struct InfoContent: Codable, Hashable {
            let title: String
            let body: String
            let imageUrl: String?
            let actionButton: ActionButton?
            
            struct ActionButton: Codable, Hashable {
                let title: String
                let url: String
            }
        }
    }
    
    // MARK: - Visibility Helper
    
    func isVisible(for perspective: PerspectiveType) -> Bool {
        visibility.isVisible(for: perspective)
    }
    
    var isFeatured: Bool {
        featured ?? false
    }
    
    // MARK: - Hashable
    
    static func == (lhs: Resource, rhs: Resource) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
