//
//  CampusEvent.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import Foundation
import SwiftUI

// MARK: - Campus Event

struct CampusEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let date: Date
    let endDate: Date?
    let location: String
    let category: CampusEventType
    let imageURL: String?
    let url: String?

    var formattedDate: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today' • h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'Tomorrow' • h:mm a"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE • h:mm a"
        } else {
            formatter.dateFormat = "EEE, MMM d • h:mm a"
        }

        return formatter.string(from: date)
    }

    var shortDate: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today'"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'Tomorrow'"
        } else {
            formatter.dateFormat = "EEE"
        }

        return formatter.string(from: date)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Campus Event Type

enum CampusEventType: String, Codable, CaseIterable {
    case athletics
    case academic
    case social
    case career
    case arts
    case other

    var color: Color {
        switch self {
        case .athletics: return .red
        case .academic: return .blue
        case .social: return .purple
        case .career: return .green
        case .arts: return .orange
        case .other: return .gray
        }
    }

    var icon: String {
        switch self {
        case .athletics: return "sportscourt.fill"
        case .academic: return "book.fill"
        case .social: return "person.3.fill"
        case .career: return "briefcase.fill"
        case .arts: return "theatermasks.fill"
        case .other: return "calendar"
        }
    }
}
