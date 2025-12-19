//
//  LiveDataService.swift
//  CampusApp
//
//  Created by Claude Code on 12/15/25.
//

import Foundation

// MARK: - Live Data Service Protocol

/// Protocol for fetching live campus data (parking, dining, wolfline, recreation)
protocol LiveDataServiceProtocol {
    func fetchParkingData() async throws -> ParkingData
    func fetchDiningData() async throws -> DiningData
    func fetchWolflineData() async throws -> WolflineData
    func fetchRecreationData() async throws -> RecreationData
}

// MARK: - Data Models

struct ParkingData: Codable {
    let lots: [ParkingLot]
    let lastUpdated: Date?

    var availableSpotsCount: Int {
        lots.filter { $0.isOpen }.reduce(0) { $0 + $1.availableSpots }
    }

    var bestLot: ParkingLot? {
        lots.filter { $0.isOpen && $0.availableSpots > 0 }
            .max { $0.availableSpots < $1.availableSpots }
    }
}

struct ParkingLot: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let availableSpots: Int
    let totalSpots: Int
    let isOpen: Bool
    let detail: String?

    var occupancy: Double {
        guard totalSpots > 0 else { return 0 }
        return 1.0 - (Double(availableSpots) / Double(totalSpots))
    }

    var statusText: String {
        if !isOpen { return "Closed" }
        if availableSpots == 0 { return "Full" }
        return "\(availableSpots) spots"
    }
}

struct DiningData: Codable {
    let halls: [DiningHall]
    let lastUpdated: Date?

    var openCount: Int {
        halls.filter { $0.isOpen }.count
    }

    var leastBusy: DiningHall? {
        halls.filter { $0.isOpen }
            .min { ($0.busyness ?? 1.0) < ($1.busyness ?? 1.0) }
    }
}

struct DiningHall: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let isOpen: Bool
    let closingTime: String?
    let busyness: Double?

    var statusText: String {
        isOpen ? "Open" : "Closed"
    }

    var busynessLabel: String {
        guard let busyness else { return "Unknown" }
        switch busyness {
        case 0..<0.4: return "Not busy"
        case 0.4..<0.7: return "Moderate"
        default: return "Busy"
        }
    }
}

struct WolflineData: Codable {
    let routes: [BusRoute]
    let lastUpdated: Date?

    var activeCount: Int {
        routes.filter { $0.isActive }.count
    }

    var nextArrival: BusRoute? {
        routes.filter { $0.isActive }
            .min { ($0.nextArrivalMinutes ?? Int.max) < ($1.nextArrivalMinutes ?? Int.max) }
    }
}

struct BusRoute: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let isActive: Bool
    let nextArrivalMinutes: Int?
    let status: String?

    var arrivalText: String {
        guard let minutes = nextArrivalMinutes else { return "No data" }
        if minutes == 0 { return "Now" }
        if minutes == 1 { return "1 min" }
        return "\(minutes) min"
    }
}

struct RecreationData: Codable {
    let areas: [RecreationArea]
    let lastUpdated: Date?

    var leastBusy: RecreationArea? {
        areas.filter { $0.isOpen }
            .min { ($0.busyness ?? 1.0) < ($1.busyness ?? 1.0) }
    }

    var averageBusyness: Double {
        let openAreas = areas.filter { $0.isOpen && $0.busyness != nil }
        guard !openAreas.isEmpty else { return 0 }
        return openAreas.compactMap { $0.busyness }.reduce(0, +) / Double(openAreas.count)
    }
}

struct RecreationArea: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let isOpen: Bool
    let busyness: Double?
    let currentCount: Int?
    let detail: String?

    var busynessLabel: String {
        guard let busyness else { return "Unknown" }
        switch busyness {
        case 0..<0.4: return "Not busy"
        case 0.4..<0.7: return "Moderate"
        default: return "Busy"
        }
    }
}

// MARK: - Mock Service Implementation

final class MockLiveDataService: LiveDataServiceProtocol {

    static let shared = MockLiveDataService()

    func fetchParkingData() async throws -> ParkingData {
        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(300))

        return ParkingData(
            lots: [
                ParkingLot(id: "dan-allen", name: "Dan Allen Deck", availableSpots: 165, totalSpots: 450, isOpen: true, detail: "Levels 1-4"),
                ParkingLot(id: "coliseum", name: "Coliseum Deck", availableSpots: 89, totalSpots: 380, isOpen: true, detail: "Levels 2-3"),
                ParkingLot(id: "reynolds", name: "Reynolds Lot", availableSpots: 23, totalSpots: 120, isOpen: true, detail: "Surface lot"),
                ParkingLot(id: "jeter", name: "Jeter Drive Lot", availableSpots: 45, totalSpots: 95, isOpen: true, detail: "West campus"),
                ParkingLot(id: "poulton", name: "Poulton Deck", availableSpots: 0, totalSpots: 320, isOpen: true, detail: "Full"),
                ParkingLot(id: "centennial", name: "Centennial Deck", availableSpots: 312, totalSpots: 650, isOpen: true, detail: "Hunt Library")
            ],
            lastUpdated: Date()
        )
    }

    func fetchDiningData() async throws -> DiningData {
        try? await Task.sleep(for: .milliseconds(300))

        return DiningData(
            halls: [
                DiningHall(id: "fountain", name: "Fountain", isOpen: true, closingTime: "9:00 PM", busyness: 0.32),
                DiningHall(id: "clark", name: "Clark", isOpen: true, closingTime: "8:00 PM", busyness: 0.65),
                DiningHall(id: "talley", name: "Talley", isOpen: true, closingTime: "10:00 PM", busyness: 0.48),
                DiningHall(id: "case", name: "Case", isOpen: true, closingTime: "7:30 PM", busyness: 0.71),
                DiningHall(id: "1887-bistro", name: "1887 Bistro", isOpen: false, closingTime: nil, busyness: nil),
                DiningHall(id: "wolves-den", name: "Wolves Den", isOpen: true, closingTime: "11:00 PM", busyness: 0.25)
            ],
            lastUpdated: Date()
        )
    }

    func fetchWolflineData() async throws -> WolflineData {
        try? await Task.sleep(for: .milliseconds(300))

        return WolflineData(
            routes: [
                BusRoute(id: "route-3", name: "Wolf Village", shortName: "3", isActive: true, nextArrivalMinutes: 2, status: "On time"),
                BusRoute(id: "route-6", name: "Gorman/Avent Ferry", shortName: "6", isActive: true, nextArrivalMinutes: 8, status: "On time"),
                BusRoute(id: "route-10", name: "Varsity", shortName: "10", isActive: true, nextArrivalMinutes: 5, status: "Delayed"),
                BusRoute(id: "route-11", name: "Trailwood", shortName: "11", isActive: true, nextArrivalMinutes: 12, status: "On time"),
                BusRoute(id: "route-21", name: "Centennial Express", shortName: "21", isActive: true, nextArrivalMinutes: 4, status: "On time"),
                BusRoute(id: "route-30", name: "Greek Village", shortName: "30", isActive: false, nextArrivalMinutes: nil, status: "Weekend only")
            ],
            lastUpdated: Date()
        )
    }

    func fetchRecreationData() async throws -> RecreationData {
        try? await Task.sleep(for: .milliseconds(300))

        return RecreationData(
            areas: [
                RecreationArea(id: "main-gym", name: "Main Gym", isOpen: true, busyness: 0.55, currentCount: 45, detail: "Open until 11 PM"),
                RecreationArea(id: "weight-room", name: "Weight Room", isOpen: true, busyness: 0.82, currentCount: 80, detail: "Very busy"),
                RecreationArea(id: "cardio", name: "Cardio", isOpen: true, busyness: 0.28, currentCount: 20, detail: "Not busy"),
                RecreationArea(id: "pool", name: "Aquatic Center", isOpen: true, busyness: 0.40, currentCount: nil, detail: "6 lanes open"),
                RecreationArea(id: "basketball", name: "Basketball", isOpen: true, busyness: 0.50, currentCount: nil, detail: "3/6 courts"),
                RecreationArea(id: "rock-wall", name: "Climbing Wall", isOpen: true, busyness: 0.15, currentCount: 8, detail: "All routes open")
            ],
            lastUpdated: Date()
        )
    }
}

// MARK: - Live Service Implementation (for future real API)

final class LiveDataService: LiveDataServiceProtocol {

    static let shared = LiveDataService()

    // In the future, these would fetch from real APIs
    // For now, delegate to mock
    private let mockService = MockLiveDataService.shared

    func fetchParkingData() async throws -> ParkingData {
        // TODO: Replace with real API call
        try await mockService.fetchParkingData()
    }

    func fetchDiningData() async throws -> DiningData {
        try await mockService.fetchDiningData()
    }

    func fetchWolflineData() async throws -> WolflineData {
        try await mockService.fetchWolflineData()
    }

    func fetchRecreationData() async throws -> RecreationData {
        try await mockService.fetchRecreationData()
    }
}
