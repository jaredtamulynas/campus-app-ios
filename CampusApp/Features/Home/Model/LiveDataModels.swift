//
//  LiveDataModels.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import SwiftUI

// MARK: - Live Widget Type

/// Types of live data widgets available on the dashboard
enum LiveWidgetType: String, Codable, CaseIterable {
    case parking
    case wolfline
    case dining
    case recreation

    var title: String {
        switch self {
        case .parking: return "Parking"
        case .wolfline: return "Wolfline"
        case .dining: return "Dining"
        case .recreation: return "Carmichael"
        }
    }

    var icon: String {
        switch self {
        case .parking: return "parkingsign.circle.fill"
        case .wolfline: return "bus.fill"
        case .dining: return "fork.knife"
        case .recreation: return "figure.run"
        }
    }

    var accentColor: Color {
        switch self {
        case .parking: return .green
        case .wolfline: return .blue
        case .dining: return .orange
        case .recreation: return .purple
        }
    }
}

// MARK: - Live Widget Data

/// Main model for displaying a live widget on the dashboard
/// Designed to be reusable between HomeView and WidgetKit
struct LiveWidgetData: Identifiable, Codable, Hashable {
    let id: String
    let type: LiveWidgetType
    let title: String
    let primaryValue: String?
    let secondaryValue: String?
    let icon: String
    let accentColorName: String
    let items: [LiveDataItem]

    var accentColor: Color {
        ColorParser.parse(accentColorName)
    }

    // MARK: - Convenience Initializer

    init(
        id: String,
        type: LiveWidgetType,
        title: String,
        primaryValue: String? = nil,
        secondaryValue: String? = nil,
        icon: String? = nil,
        accentColorName: String? = nil,
        items: [LiveDataItem] = []
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.icon = icon ?? type.icon
        self.accentColorName = accentColorName ?? type.accentColor.description
        self.items = items
    }

    // MARK: - Hashable

    static func == (lhs: LiveWidgetData, rhs: LiveWidgetData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Live Data Item

/// Individual item within a live widget (parking lot, bus route, dining hall, etc.)
struct LiveDataItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let status: String
    let detail: String?
    let capacity: Double?
    let isOpen: Bool
    let lastUpdated: Date?

    init(
        id: String,
        name: String,
        status: String,
        detail: String? = nil,
        capacity: Double? = nil,
        isOpen: Bool = true,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.detail = detail
        self.capacity = capacity
        self.isOpen = isOpen
        self.lastUpdated = lastUpdated
    }

    // MARK: - Capacity Helpers

    var capacityLevel: CapacityLevel {
        guard let capacity else { return .unknown }
        switch capacity {
        case 0..<0.4: return .low
        case 0.4..<0.7: return .moderate
        case 0.7...1.0: return .high
        default: return .unknown
        }
    }

    enum CapacityLevel: String {
        case low, moderate, high, unknown

        var color: Color {
            switch self {
            case .low: return .green
            case .moderate: return .orange
            case .high: return .red
            case .unknown: return .secondary
            }
        }

        var label: String {
            switch self {
            case .low: return "Not busy"
            case .moderate: return "Moderate"
            case .high: return "Very busy"
            case .unknown: return "Unknown"
            }
        }
    }
}

// MARK: - Mock Data

extension LiveWidgetData {

    /// Mock data for development and previews
    static var mockParkingWidget: LiveWidgetData {
        LiveWidgetData(
            id: "parking",
            type: .parking,
            title: "Parking",
            primaryValue: "Dan Allen Deck",
            secondaryValue: "165 open spots",
            items: LiveDataItem.mockParkingItems
        )
    }

    static var mockWolflineWidget: LiveWidgetData {
        LiveWidgetData(
            id: "wolfline",
            type: .wolfline,
            title: "Wolfline",
            primaryValue: "Route 3 • Wolf Village",
            secondaryValue: "Next bus • 2 min",
            items: LiveDataItem.mockWolflineItems
        )
    }

    static var mockDiningWidget: LiveWidgetData {
        LiveWidgetData(
            id: "dining",
            type: .dining,
            title: "Dining",
            primaryValue: "Fountain Dining",
            secondaryValue: "Low wait • Open",
            items: LiveDataItem.mockDiningItems
        )
    }

    static var mockRecreationWidget: LiveWidgetData {
        LiveWidgetData(
            id: "recreation",
            type: .recreation,
            title: "Carmichael",
            primaryValue: nil,
            secondaryValue: nil,
            items: LiveDataItem.mockRecreationItems
        )
    }

    static var allMockWidgets: [LiveWidgetData] {
        [mockWolflineWidget, mockParkingWidget, mockDiningWidget, mockRecreationWidget]
    }
}

extension LiveDataItem {

    // MARK: - Parking Mock Data

    static var mockParkingItems: [LiveDataItem] {
        [
            LiveDataItem(id: "dan-allen", name: "Dan Allen Deck", status: "165 spots", detail: "Levels 1-4 available", capacity: 0.35),
            LiveDataItem(id: "coliseum", name: "Coliseum Deck", status: "89 spots", detail: "Levels 2-3 available", capacity: 0.55),
            LiveDataItem(id: "reynolds", name: "Reynolds Coliseum Lot", status: "23 spots", detail: "Surface lot", capacity: 0.78),
            LiveDataItem(id: "jeter", name: "Jeter Drive Lot", status: "45 spots", detail: "West campus", capacity: 0.42),
            LiveDataItem(id: "poulton", name: "Poulton Deck", status: "Full", detail: "No availability", capacity: 1.0, isOpen: true),
            LiveDataItem(id: "centennial", name: "Centennial Campus Deck", status: "312 spots", detail: "Near Hunt Library", capacity: 0.22)
        ]
    }

    // MARK: - Wolfline Mock Data

    static var mockWolflineItems: [LiveDataItem] {
        [
            LiveDataItem(id: "route-3", name: "Route 3 - Wolf Village", status: "Next: 2 min", detail: "On time", capacity: nil),
            LiveDataItem(id: "route-6", name: "Route 6 - Gorman/Avent Ferry", status: "Next: 8 min", detail: "On time", capacity: nil),
            LiveDataItem(id: "route-10", name: "Route 10 - Varsity", status: "Next: 5 min", detail: "Delayed 3 min", capacity: nil),
            LiveDataItem(id: "route-11", name: "Route 11 - Trailwood", status: "Next: 12 min", detail: "On time", capacity: nil),
            LiveDataItem(id: "route-21", name: "Route 21 - Centennial Express", status: "Next: 4 min", detail: "On time", capacity: nil),
            LiveDataItem(id: "route-30", name: "Route 30 - Greek Village", status: "Not running", detail: "Weekend only", capacity: nil, isOpen: false)
        ]
    }

    // MARK: - Dining Mock Data

    static var mockDiningItems: [LiveDataItem] {
        [
            LiveDataItem(id: "fountain", name: "Fountain Dining Hall", status: "Open", detail: "Until 9:00 PM", capacity: 0.32),
            LiveDataItem(id: "clark", name: "Clark Dining Hall", status: "Open", detail: "Until 8:00 PM", capacity: 0.65),
            LiveDataItem(id: "talley", name: "Talley Student Union", status: "Open", detail: "Multiple options", capacity: 0.48),
            LiveDataItem(id: "case", name: "Case Dining Hall", status: "Open", detail: "Until 7:30 PM", capacity: 0.71),
            LiveDataItem(id: "1887-bistro", name: "1887 Bistro", status: "Closed", detail: "Opens 11:00 AM", capacity: nil, isOpen: false),
            LiveDataItem(id: "wolves-den", name: "Wolves Den", status: "Open", detail: "Late night available", capacity: 0.25)
        ]
    }

    // MARK: - Recreation Mock Data

    static var mockRecreationItems: [LiveDataItem] {
        [
            LiveDataItem(id: "main-gym", name: "Main Gym Floor", status: "Moderate", detail: "~45 people", capacity: 0.55),
            LiveDataItem(id: "weight-room", name: "Weight Room", status: "Busy", detail: "~80 people", capacity: 0.82),
            LiveDataItem(id: "cardio", name: "Cardio Area", status: "Not busy", detail: "~20 people", capacity: 0.28),
            LiveDataItem(id: "pool", name: "Aquatic Center", status: "Lap swim", detail: "6 lanes open", capacity: 0.40),
            LiveDataItem(id: "basketball", name: "Basketball Courts", status: "3/6 courts free", detail: "Open play", capacity: 0.50),
            LiveDataItem(id: "rock-wall", name: "Climbing Wall", status: "Available", detail: "All routes open", capacity: 0.15, isOpen: true)
        ]
    }
}
