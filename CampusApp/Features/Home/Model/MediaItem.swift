//
//  MediaItem.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

/// Model for campus media items (radio, TV, news, podcasts)
/// Pulls data from CampusConfig.mediaLinks
struct MediaItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let url: String
    let color: Color
    let icon: String
    let streamURL: String?
    let type: MediaType

    enum MediaType: String {
        case radio
        case tv
        case news
        case podcast
        case other
    }

    /// Creates media items from campus configuration
    static func from(config: CampusConfig) -> [MediaItem] {
        guard let links = config.mediaLinks, !links.isEmpty else {
            return []
        }

        return links.map { link in
            MediaItem(
                id: link.id,
                title: link.title,
                subtitle: link.subtitle,
                url: link.url,
                color: ColorParser.parse(link.color),
                icon: link.icon ?? "link.circle.fill",
                streamURL: link.streamURL,
                type: inferMediaType(from: link.id)
            )
        }
    }

    private static func inferMediaType(from id: String) -> MediaType {
        switch id.lowercased() {
        case let id where id.contains("radio") || id.contains("wknc"):
            return .radio
        case let id where id.contains("tv") || id.contains("wolfbytes"):
            return .tv
        case let id where id.contains("news") || id.contains("technician"):
            return .news
        case let id where id.contains("podcast"):
            return .podcast
        default:
            return .other
        }
    }
}
