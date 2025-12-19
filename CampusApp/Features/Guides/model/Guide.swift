//
//  Guide.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/3/25.
//

import Foundation

// MARK: - Guide

struct Guide: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let department: String
    let description: String
    let headerImageUrl: String?
    let icon: String
    let color: String
    let visibility: PerspectiveVisibility
    let featured: Bool?
    let alert: GuideAlert?
    
    // Content sections (flexible info blocks)
    let sections: [GuideSection]?
    
    // Events (filterable, RSVP-able, add to calendar)
    let events: [GuideEvent]?
    
    // Locations (shows inline map when provided)
    let locations: [GuideLocation]?
    
    // Todos (user-checkable tasks with progress tracking)
    let todos: [GuideTodo]?
    
    // FAQs (expandable Q&A)
    let faqs: [GuideFAQ]?
    
    // Contacts (people/departments)
    let contacts: [GuideContact]?
    
    // Links (quick links/resources)
    let links: [GuideLink]?
    
    // Updates/Announcements for this guide
    let updates: [GuideUpdate]?
    
    // MARK: - Computed Properties
    
    var isFeatured: Bool {
        featured ?? false
    }
    
    var hasEvents: Bool {
        !(events?.isEmpty ?? true)
    }
    
    var hasLocations: Bool {
        !(locations?.isEmpty ?? true)
    }
    
    var hasTodos: Bool {
        !(todos?.isEmpty ?? true)
    }
    
    var hasFAQs: Bool {
        !(faqs?.isEmpty ?? true)
    }
    
    var hasContacts: Bool {
        !(contacts?.isEmpty ?? true)
    }
    
    var hasLinks: Bool {
        !(links?.isEmpty ?? true)
    }
    
    var hasUpdates: Bool {
        !(updates?.isEmpty ?? true)
    }
    
    var hasSections: Bool {
        !(sections?.isEmpty ?? true)
    }
    
    // MARK: - Visibility Helper
    
    func isVisible(for perspective: PerspectiveType) -> Bool {
        visibility.isVisible(for: perspective)
    }
    
    // MARK: - Hashable
    
    static func == (lhs: Guide, rhs: Guide) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Guide Section

struct GuideSection: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let order: Int
    let content: String  // Markdown/rich text content
    
    static func == (lhs: GuideSection, rhs: GuideSection) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Guide Event

struct GuideEvent: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String?
    let category: EventCategory
    let startDate: String       // ISO 8601 or human-readable
    let endDate: String?
    let location: String?
    let locationId: String?     // Links to GuideLocation for map highlight
    let isRequired: Bool?
    
    var isRequiredEvent: Bool {
        isRequired ?? false
    }
    
    static func == (lhs: GuideEvent, rhs: GuideEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum EventCategory: String, Codable, CaseIterable {
    case academic
    case social
    case orientation
    case sports
    case club
    case workshop
    case dining
    case other
    
    var displayName: String {
        switch self {
        case .academic: return "Academic"
        case .social: return "Social"
        case .orientation: return "Orientation"
        case .sports: return "Sports"
        case .club: return "Club"
        case .workshop: return "Workshop"
        case .dining: return "Dining"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .academic: return "book.fill"
        case .social: return "person.3.fill"
        case .orientation: return "graduationcap.fill"
        case .sports: return "sportscourt.fill"
        case .club: return "star.fill"
        case .workshop: return "wrench.fill"
        case .dining: return "fork.knife"
        case .other: return "calendar"
        }
    }
}

// MARK: - Guide Location

struct GuideLocation: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    let latitude: Double
    let longitude: Double
    let address: String?
    let category: LocationCategory?
    let icon: String?
    
    var coordinate: (latitude: Double, longitude: Double) {
        (latitude, longitude)
    }
    
    static func == (lhs: GuideLocation, rhs: GuideLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum LocationCategory: String, Codable, CaseIterable {
    case building
    case dining
    case parking
    case venue
    case dorm
    case shuttle
    case library
    case recreation
    case other
    
    var displayName: String {
        switch self {
        case .building: return "Building"
        case .dining: return "Dining"
        case .parking: return "Parking"
        case .venue: return "Venue"
        case .dorm: return "Residence Hall"
        case .shuttle: return "Shuttle Stop"
        case .library: return "Library"
        case .recreation: return "Recreation"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .building: return "building.2.fill"
        case .dining: return "fork.knife"
        case .parking: return "car.fill"
        case .venue: return "music.mic"
        case .dorm: return "bed.double.fill"
        case .shuttle: return "bus.fill"
        case .library: return "books.vertical.fill"
        case .recreation: return "figure.run"
        case .other: return "mappin"
        }
    }
}

// MARK: - Guide Todo

struct GuideTodo: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String?
    let dueDate: String?
    let priority: TodoPriority?
    let category: String?
    let linkedUrl: String?      // Optional link to complete the task
    
    var priorityLevel: TodoPriority {
        priority ?? .medium
    }
    
    static func == (lhs: GuideTodo, rhs: GuideTodo) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum TodoPriority: String, Codable {
    case low
    case medium
    case high
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

// MARK: - Guide FAQ

struct GuideFAQ: Identifiable, Codable, Hashable {
    let id: String
    let question: String
    let answer: String
    let category: String?
    
    static func == (lhs: GuideFAQ, rhs: GuideFAQ) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Guide Contact

struct GuideContact: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let role: String?
    let phone: String?
    let email: String?
    
    static func == (lhs: GuideContact, rhs: GuideContact) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Guide Link

struct GuideLink: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let url: String
    let icon: String?
    let description: String?
    
    static func == (lhs: GuideLink, rhs: GuideLink) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Guide Update

struct GuideUpdate: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let message: String
    let timestamp: String
    let type: UpdateType
    
    static func == (lhs: GuideUpdate, rhs: GuideUpdate) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum UpdateType: String, Codable {
    case info
    case change
    case urgent
    case cancellation
    
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .change: return "arrow.triangle.2.circlepath"
        case .urgent: return "exclamationmark.triangle.fill"
        case .cancellation: return "xmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .info: return "blue"
        case .change: return "orange"
        case .urgent: return "red"
        case .cancellation: return "gray"
        }
    }
}

// MARK: - Guide Alert

struct GuideAlert: Codable, Hashable {
    let type: AlertType
    let message: String
    
    enum AlertType: String, Codable {
        case info
        case action
        case deadline
        case success
        case new
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .action: return "exclamationmark.circle.fill"
            case .deadline: return "clock.fill"
            case .success: return "checkmark.circle.fill"
            case .new: return "sparkles"
            }
        }
        
        var color: String {
            switch self {
            case .info: return "blue"
            case .action: return "orange"
            case .deadline: return "red"
            case .success: return "green"
            case .new: return "purple"
            }
        }
    }
}

// MARK: - Guides Data Container

struct GuidesData: Codable {
    let guides: [Guide]
    let lastUpdated: String?
    
    func visibleGuides(for perspective: PerspectiveType) -> [Guide] {
        return guides.filter { $0.isVisible(for: perspective) }
    }
}
