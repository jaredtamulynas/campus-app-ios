//
//  HomeViewModel.swift
//  CampusApp
//
//  Created by Claude Code on 12/15/25.
//

import Foundation

@Observable
final class HomeViewModel {

    // MARK: - Data State

    private(set) var parkingData: ParkingData?
    private(set) var diningData: DiningData?
    private(set) var wolflineData: WolflineData?
    private(set) var recreationData: RecreationData?
    private(set) var eventsData: EventsData?

    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Services

    private let liveDataService: LiveDataServiceProtocol
    private let eventsService: EventsServiceProtocol

    // MARK: - Init

    init(
        liveDataService: LiveDataServiceProtocol = LiveDataService.shared,
        eventsService: EventsServiceProtocol = EventsService.shared
    ) {
        self.liveDataService = liveDataService
        self.eventsService = eventsService
    }

    // MARK: - Computed Properties for Widgets

    var parkingWidget: LiveWidgetDisplay {
        guard let data = parkingData, let best = data.bestLot else {
            return LiveWidgetDisplay(
                type: .parking,
                primaryLabel: "Loading...",
                primaryValue: "--",
                secondaryLabel: nil,
                secondaryValue: nil,
                accentValue: nil,
                isLoading: parkingData == nil
            )
        }

        return LiveWidgetDisplay(
            type: .parking,
            primaryLabel: best.name,
            primaryValue: "\(best.availableSpots)",
            secondaryLabel: "spots open",
            secondaryValue: nil,
            accentValue: best.occupancy,
            isLoading: false
        )
    }

    var diningWidget: LiveWidgetDisplay {
        guard let data = diningData, let best = data.leastBusy else {
            return LiveWidgetDisplay(
                type: .dining,
                primaryLabel: "Loading...",
                primaryValue: "--",
                secondaryLabel: nil,
                secondaryValue: nil,
                accentValue: nil,
                isLoading: diningData == nil
            )
        }

        return LiveWidgetDisplay(
            type: .dining,
            primaryLabel: best.name,
            primaryValue: best.busynessLabel,
            secondaryLabel: best.closingTime.map { "until \($0)" },
            secondaryValue: nil,
            accentValue: best.busyness,
            isLoading: false
        )
    }

    var wolflineWidget: LiveWidgetDisplay {
        guard let data = wolflineData, let next = data.nextArrival else {
            return LiveWidgetDisplay(
                type: .wolfline,
                primaryLabel: "Loading...",
                primaryValue: "--",
                secondaryLabel: nil,
                secondaryValue: nil,
                accentValue: nil,
                isLoading: wolflineData == nil
            )
        }

        return LiveWidgetDisplay(
            type: .wolfline,
            primaryLabel: "Route \(next.shortName)",
            primaryValue: next.arrivalText,
            secondaryLabel: next.name,
            secondaryValue: next.status,
            accentValue: nil,
            isLoading: false
        )
    }

    var recreationWidget: LiveWidgetDisplay {
        guard let data = recreationData, let best = data.leastBusy else {
            return LiveWidgetDisplay(
                type: .recreation,
                primaryLabel: "Loading...",
                primaryValue: "--",
                secondaryLabel: nil,
                secondaryValue: nil,
                accentValue: nil,
                isLoading: recreationData == nil
            )
        }

        return LiveWidgetDisplay(
            type: .recreation,
            primaryLabel: best.name,
            primaryValue: best.busynessLabel,
            secondaryLabel: best.detail,
            secondaryValue: nil,
            accentValue: best.busyness,
            isLoading: false
        )
    }

    var upcomingEvents: [CampusEvent] {
        eventsData?.events
            .sorted { $0.date < $1.date }
            .prefix(6)
            .map { $0 } ?? []
    }

    // MARK: - Loading

    func loadData() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadParking() }
            group.addTask { await self.loadDining() }
            group.addTask { await self.loadWolfline() }
            group.addTask { await self.loadRecreation() }
            group.addTask { await self.loadEvents() }
        }

        isLoading = false
    }

    private func loadParking() async {
        do {
            parkingData = try await liveDataService.fetchParkingData()
        } catch {
            self.error = error
        }
    }

    private func loadDining() async {
        do {
            diningData = try await liveDataService.fetchDiningData()
        } catch {
            self.error = error
        }
    }

    private func loadWolfline() async {
        do {
            wolflineData = try await liveDataService.fetchWolflineData()
        } catch {
            self.error = error
        }
    }

    private func loadRecreation() async {
        do {
            recreationData = try await liveDataService.fetchRecreationData()
        } catch {
            self.error = error
        }
    }

    private func loadEvents() async {
        do {
            eventsData = try await eventsService.fetchEvents()
        } catch {
            self.error = error
        }
    }
}

// MARK: - Live Widget Display Model

/// Presentation model for displaying live widgets
struct LiveWidgetDisplay: Identifiable {
    let id: String
    let type: LiveWidgetType
    let primaryLabel: String
    let primaryValue: String
    let secondaryLabel: String?
    let secondaryValue: String?
    let accentValue: Double? // For progress indicators (0-1)
    let isLoading: Bool

    init(
        type: LiveWidgetType,
        primaryLabel: String,
        primaryValue: String,
        secondaryLabel: String?,
        secondaryValue: String?,
        accentValue: Double?,
        isLoading: Bool
    ) {
        self.id = type.rawValue
        self.type = type
        self.primaryLabel = primaryLabel
        self.primaryValue = primaryValue
        self.secondaryLabel = secondaryLabel
        self.secondaryValue = secondaryValue
        self.accentValue = accentValue
        self.isLoading = isLoading
    }
}
