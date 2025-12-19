//
//  AccountItem.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/14/25.
//

import Foundation

struct AccountData: Codable {
    let sections: [AccountSection]
    let lastUpdated: String?
}

struct AccountSection: Codable, Identifiable {
    let id: String
    let title: String
    let items: [AccountItem]
}

struct AccountItem: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String
    let iconColorName: String?
    let type: AccountItemType
    let destination: AccountDestination?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, icon
        case iconColorName = "iconColor"
        case type, destination
    }
    
    enum AccountItemType: String, Codable {
        case navigationLink
        case externalLink
        case email
        case `static`
    }
    
    struct AccountDestination: Codable {
        let viewIdentifier: String?
        let url: String?
    }
}

