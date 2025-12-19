//
//  RecreationDetailView.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import SwiftUI

struct RecreationDetailView: View {
    let data: RecreationData?

    @State private var selectedArea: RecreationArea?

    private var areas: [RecreationArea] {
        data?.areas ?? []
    }

    private var openAreas: [RecreationArea] {
        areas.filter { $0.isOpen }
            .sorted { ($0.busyness ?? 1.0) < ($1.busyness ?? 1.0) }
    }

    private var closedAreas: [RecreationArea] {
        areas.filter { !$0.isOpen }
    }

    var body: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            if !openAreas.isEmpty {
                Section("Open") {
                    ForEach(openAreas) { area in
                        Button {
                            selectedArea = area
                        } label: {
                            FacilityRow(area: area)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !closedAreas.isEmpty {
                Section("Closed") {
                    ForEach(closedAreas) { area in
                        Button {
                            selectedArea = area
                        } label: {
                            FacilityRow(area: area)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Carmichael")
        .sheet(item: $selectedArea) { area in
            FacilityDetailSheet(area: area)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.run")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.purple.gradient, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Carmichael Complex")
                        .font(.headline)
                    Text("\(openAreas.count) facilities open")
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

// MARK: - Facility Row

private struct FacilityRow: View {
    let area: RecreationArea

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForArea(area.id))
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(area.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(area.isOpen ? .primary : .secondary)

                if let detail = area.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if area.isOpen, let busyness = area.busyness {
                OccupancyBadge(level: busyness, label: area.busynessLabel)
            } else if !area.isOpen {
                Text("Closed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func iconForArea(_ id: String) -> String {
        switch id {
        case "main-gym": return "figure.strengthtraining.traditional"
        case "weight-room": return "dumbbell.fill"
        case "cardio": return "figure.run"
        case "pool": return "figure.pool.swim"
        case "basketball": return "basketball.fill"
        case "rock-wall": return "figure.climbing"
        default: return "figure.mixed.cardio"
        }
    }
}

// MARK: - Occupancy Badge

private struct OccupancyBadge: View {
    let level: Double
    let label: String

    private var color: Color {
        switch level {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }

    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Facility Detail Sheet

private struct FacilityDetailSheet: View {
    let area: RecreationArea
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "figure.run")
                                .font(.largeTitle)
                                .foregroundStyle(.purple)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(area.name)
                                    .font(.headline)
                                Text(area.isOpen ? area.busynessLabel : "Closed")
                                    .font(.subheadline)
                                    .foregroundStyle(busynessColor(for: area.busyness ?? 0))
                            }
                        }

                        if area.isOpen, let busyness = area.busyness {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Occupancy")
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

                                HStack {
                                    Text("\(Int(busyness * 100))% capacity")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    if let count = area.currentCount {
                                        Text("~\(count) people")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                if let detail = area.detail {
                    Section("Info") {
                        Text(detail)
                    }
                }

                Section("Typical Busy Times") {
                    BusyTimeRow(time: "6 AM - 8 AM", level: 0.3)
                    BusyTimeRow(time: "11 AM - 1 PM", level: 0.6)
                    BusyTimeRow(time: "4 PM - 7 PM", level: 0.9)
                    BusyTimeRow(time: "8 PM - 10 PM", level: 0.4)
                }

                Section {
                    Button {
                        // Future: Set as favorite
                    } label: {
                        Label("Set as Favorite", systemImage: "star")
                    }

                    Button {
                        // Future: View schedule
                    } label: {
                        Label("View Schedule", systemImage: "calendar")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(area.name)
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

private struct BusyTimeRow: View {
    let time: String
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
        case 0..<0.4: return "Usually not busy"
        case 0.4..<0.7: return "Usually moderate"
        default: return "Usually busy"
        }
    }

    var body: some View {
        HStack {
            Text(time)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < Int(level * 3) + 1 ? color : Color(.systemGray4))
                        .frame(width: 8, height: 16)
                }
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    RecreationDetailView(data: nil)
}
