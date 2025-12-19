//
//  DiningDetailView.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import SwiftUI

struct DiningDetailView: View {
    let data: DiningData?

    @State private var selectedHall: DiningHall?

    private var diningHalls: [DiningHall] {
        data?.halls ?? []
    }

    private var openHalls: [DiningHall] {
        diningHalls.filter { $0.isOpen }
            .sorted { ($0.busyness ?? 1.0) < ($1.busyness ?? 1.0) }
    }

    private var closedHalls: [DiningHall] {
        diningHalls.filter { !$0.isOpen }
    }

    var body: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            if !openHalls.isEmpty {
                Section("Open Now") {
                    ForEach(openHalls) { hall in
                        Button {
                            selectedHall = hall
                        } label: {
                            DiningHallRow(hall: hall)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !closedHalls.isEmpty {
                Section("Closed") {
                    ForEach(closedHalls) { hall in
                        Button {
                            selectedHall = hall
                        } label: {
                            DiningHallRow(hall: hall)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Dining")
        .sheet(item: $selectedHall) { hall in
            DiningHallDetailSheet(hall: hall)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.orange.gradient, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Campus Dining")
                        .font(.headline)
                    Text("\(data?.openCount ?? 0) locations open")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                LiveBadge()
            }

            if let best = data?.leastBusy {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("Least busy: \(best.name)")
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

// MARK: - Dining Hall Row

private struct DiningHallRow: View {
    let hall: DiningHall

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(hall.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(hall.isOpen ? .primary : .secondary)

                HStack(spacing: 8) {
                    Text(hall.statusText)
                        .font(.caption)
                        .foregroundStyle(hall.isOpen ? .green : .secondary)

                    if let closingTime = hall.closingTime {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("until \(closingTime)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if hall.isOpen, let busyness = hall.busyness {
                BusynessIndicator(level: busyness)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Busyness Indicator

private struct BusynessIndicator: View {
    let level: Double

    private var color: Color {
        switch level {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }

    private var label: String {
        switch level {
        case 0..<0.4: return "Low"
        case 0.4..<0.7: return "Moderate"
        default: return "Busy"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Dining Hall Detail Sheet

private struct DiningHallDetailSheet: View {
    let hall: DiningHall
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .font(.largeTitle)
                                .foregroundStyle(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(hall.name)
                                    .font(.headline)
                                Text(hall.statusText)
                                    .font(.subheadline)
                                    .foregroundStyle(hall.isOpen ? .green : .secondary)
                            }
                        }

                        if hall.isOpen, let busyness = hall.busyness {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Busyness")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.quaternary)

                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(busynessColor(for: busyness))
                                            .frame(width: geometry.size.width * min(busyness, 1.0))
                                    }
                                }
                                .frame(height: 12)

                                Text(hall.busynessLabel)
                                    .font(.caption)
                                    .foregroundStyle(busynessColor(for: busyness))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Hours") {
                    if let closingTime = hall.closingTime {
                        LabeledContent("Closes", value: closingTime)
                    }
                    LabeledContent("Status", value: hall.isOpen ? "Open" : "Closed")
                }

                Section {
                    Button {
                        // Future: Set as favorite
                    } label: {
                        Label("Set as Favorite", systemImage: "star")
                    }

                    Button {
                        // Future: View menu
                    } label: {
                        Label("View Today's Menu", systemImage: "menucard")
                    }

                    Button {
                        // Future: Open in Maps
                    } label: {
                        Label("Get Directions", systemImage: "map")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(hall.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func busynessColor(for value: Double) -> Color {
        switch value {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    DiningDetailView(data: nil)
}
