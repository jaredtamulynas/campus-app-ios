//
//  EventsService.swift
//  CampusApp
//
//  Created by Claude Code on 12/15/25.
//

import Foundation

// MARK: - Events Service Protocol

protocol EventsServiceProtocol {
    func fetchEvents() async throws -> EventsData
}

// MARK: - Events Data

struct EventsData {
    let events: [CampusEvent]
    let lastUpdated: Date?
}

// MARK: - Mock Service Implementation

final class MockEventsService: EventsServiceProtocol {

    static let shared = MockEventsService()

    func fetchEvents() async throws -> EventsData {
        try? await Task.sleep(for: .milliseconds(300))

        let calendar = Calendar.current
        let now = Date()

        return EventsData(
            events: [
                CampusEvent(
                    id: "football-duke",
                    title: "Football vs. Duke",
                    subtitle: "ACC Conference Game",
                    date: calendar.date(byAdding: .day, value: 2, to: now)!.addingTimeInterval(15.5 * 3600),
                    endDate: nil,
                    location: "Carter-Finley Stadium",
                    category: .athletics,
                    imageURL: nil,
                    url: nil
                ),
                CampusEvent(
                    id: "career-fair",
                    title: "Engineering Career Fair",
                    subtitle: "100+ companies recruiting",
                    date: calendar.date(byAdding: .day, value: 1, to: now)!.addingTimeInterval(10 * 3600),
                    endDate: calendar.date(byAdding: .day, value: 1, to: now)!.addingTimeInterval(16 * 3600),
                    location: "Talley Ballroom",
                    category: .career,
                    imageURL: nil,
                    url: nil
                ),
                CampusEvent(
                    id: "study-abroad",
                    title: "Study Abroad Info Session",
                    subtitle: "Spring 2026 programs",
                    date: calendar.date(byAdding: .day, value: 3, to: now)!.addingTimeInterval(14 * 3600),
                    endDate: nil,
                    location: "Witherspoon 126",
                    category: .academic,
                    imageURL: nil,
                    url: nil
                ),
                CampusEvent(
                    id: "basketball-unc",
                    title: "Basketball vs. UNC",
                    subtitle: "Rivalry Game",
                    date: calendar.date(byAdding: .day, value: 5, to: now)!.addingTimeInterval(19 * 3600),
                    endDate: nil,
                    location: "PNC Arena",
                    category: .athletics,
                    imageURL: nil,
                    url: nil
                ),
                CampusEvent(
                    id: "art-exhibit",
                    title: "Student Art Exhibition",
                    subtitle: "Senior showcase",
                    date: calendar.date(byAdding: .day, value: 4, to: now)!.addingTimeInterval(18 * 3600),
                    endDate: nil,
                    location: "Gregg Museum",
                    category: .arts,
                    imageURL: nil,
                    url: nil
                ),
                CampusEvent(
                    id: "hackathon",
                    title: "PackHacks 2025",
                    subtitle: "24-hour hackathon",
                    date: calendar.date(byAdding: .day, value: 7, to: now)!.addingTimeInterval(12 * 3600),
                    endDate: calendar.date(byAdding: .day, value: 8, to: now)!.addingTimeInterval(12 * 3600),
                    location: "Hunt Library",
                    category: .academic,
                    imageURL: nil,
                    url: nil
                )
            ],
            lastUpdated: Date()
        )
    }
}

// MARK: - Live Service Implementation

final class EventsService: EventsServiceProtocol {

    static let shared = EventsService()

    private let mockService = MockEventsService.shared

    func fetchEvents() async throws -> EventsData {
        // TODO: Replace with real API call
        try await mockService.fetchEvents()
    }
}
