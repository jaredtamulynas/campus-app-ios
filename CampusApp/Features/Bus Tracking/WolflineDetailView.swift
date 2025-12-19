//
//  WolflineDetailView.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import SwiftUI

struct WolflineDetailView: View {
    let data: WolflineData?

    @State private var selectedRoute: BusRoute?

    private var routes: [BusRoute] {
        data?.routes ?? []
    }

    private var activeRoutes: [BusRoute] {
        routes.filter { $0.isActive }
            .sorted { ($0.nextArrivalMinutes ?? Int.max) < ($1.nextArrivalMinutes ?? Int.max) }
    }

    private var inactiveRoutes: [BusRoute] {
        routes.filter { !$0.isActive }
    }

    var body: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            if !activeRoutes.isEmpty {
                Section("Active Routes") {
                    ForEach(activeRoutes) { route in
                        Button {
                            selectedRoute = route
                        } label: {
                            RouteRow(route: route)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !inactiveRoutes.isEmpty {
                Section("Not Running") {
                    ForEach(inactiveRoutes) { route in
                        Button {
                            selectedRoute = route
                        } label: {
                            RouteRow(route: route)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Wolfline")
        .sheet(item: $selectedRoute) { route in
            RouteDetailSheet(route: route)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bus.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.blue.gradient, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Wolfline Bus Service")
                        .font(.headline)
                    Text("\(data?.activeCount ?? 0) routes active")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                LiveBadge()
            }

            if let next = data?.nextArrival {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Next: Route \(next.shortName) in \(next.arrivalText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Route Row

private struct RouteRow: View {
    let route: BusRoute

    var body: some View {
        HStack(spacing: 12) {
            // Route number badge
            Text(route.shortName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(route.isActive ? Color.blue : Color.secondary, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(route.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(route.isActive ? .primary : .secondary)

                if let status = route.status {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(status.contains("Delay") ? .orange : .secondary)
                }
            }

            Spacer()

            if route.isActive {
                Text(route.arrivalText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Route Detail Sheet

private struct RouteDetailSheet: View {
    let route: BusRoute
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(route.shortName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(route.isActive ? Color.blue : Color.secondary, in: Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(route.name)
                                    .font(.headline)
                                if route.isActive {
                                    Text("Next arrival: \(route.arrivalText)")
                                        .font(.subheadline)
                                        .foregroundStyle(.blue)
                                } else {
                                    Text("Not currently running")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        if !route.isActive {
                            Label("This route is not currently running", systemImage: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Status") {
                    if let status = route.status {
                        LabeledContent("Info", value: status)
                    }
                    LabeledContent("Running", value: route.isActive ? "Yes" : "No")
                }

                if route.isActive {
                    Section("Upcoming Arrivals") {
                        ArrivalRow(stop: "Your Stop", time: route.arrivalText)
                        ArrivalRow(stop: "Next Stop", time: "+5 min")
                        ArrivalRow(stop: "Following", time: "+12 min")
                    }
                }

                Section {
                    Button {
                        // Future: Set as favorite
                    } label: {
                        Label("Set as Favorite Route", systemImage: "star")
                    }

                    Button {
                        // Future: Open TransLoc or similar
                    } label: {
                        Label("Track Bus Location", systemImage: "location")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Route \(route.shortName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct ArrivalRow: View {
    let stop: String
    let time: String

    var body: some View {
        HStack {
            Text(stop)
                .foregroundStyle(.secondary)
            Spacer()
            Text(time)
                .fontWeight(.medium)
                .foregroundStyle(.blue)
        }
    }
}

// MARK: - Preview

#Preview {
    WolflineDetailView(data: nil)
}
