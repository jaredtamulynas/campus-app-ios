//
//  CampusMessage.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/25/25.
//

import Foundation

/// Simple message model designed for Firebase Cloud Messaging (FCM)
struct CampusMessage: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let timestamp: Date
    let actionUrl: String?
    var isRead: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        timestamp: Date = Date(),
        actionUrl: String? = nil,
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.actionUrl = actionUrl
        self.isRead = isRead
    }

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    var actionURL: URL? {
        guard let actionUrl else { return nil }
        return URL(string: actionUrl)
    }
}

// MARK: - Sample Data

extension CampusMessage {
    static let samples: [CampusMessage] = [
        CampusMessage(
            title: "Spring Registration Opens Monday",
            body: "Course registration for Spring 2026 begins Monday. Check your registration window in MyPack Portal.",
            timestamp: Date().addingTimeInterval(-3600),
            actionUrl: "https://mypack.ncsu.edu"
        ),
        CampusMessage(
            title: "Basketball: Pack vs Duke",
            body: "Join us at PNC Arena for the biggest game of the season! Doors open at 5:30 PM.",
            timestamp: Date().addingTimeInterval(-86400)
        ),
        CampusMessage(
            title: "Library Hours Extended",
            body: "D.H. Hill Library will have extended hours during finals week: Open 24/7 from December 1-15.",
            timestamp: Date().addingTimeInterval(-172800),
            isRead: true
        )
    ]
}
