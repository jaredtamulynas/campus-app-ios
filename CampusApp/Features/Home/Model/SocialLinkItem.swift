//
//  SocialLinkItem.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

/// Model for social media links displayed on the home screen
/// Pulls data from CampusConfig.socialLinks
struct SocialLinkItem: Identifiable {
    let id: String
    let title: String
    let url: String
    let assetName: String
    let accent: Color

    /// Creates social link items from campus configuration
    /// Falls back to empty array if no social links are configured
    static func from(config: CampusConfig) -> [SocialLinkItem] {
        guard let links = config.socialLinks, !links.isEmpty else {
            return []
        }

        return links.map { link in
            SocialLinkItem(
                id: link.id,
                title: link.title,
                url: link.url,
                assetName: link.assetName,
                accent: ColorParser.parse(link.color)
            )
        }
    }
}
