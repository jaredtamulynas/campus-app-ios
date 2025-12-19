//
//  ParkingDetailView.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import SwiftUI

struct ParkingDetailView: View {
    let data: ParkingData?

    @State private var selectedLot: ParkingLot?

    private var parkingLots: [ParkingLot] {
        data?.lots ?? []
    }

    private var openLots: [ParkingLot] {
        parkingLots.filter { $0.isOpen && $0.availableSpots > 0 }
            .sorted { $0.availableSpots > $1.availableSpots }
    }

    private var fullLots: [ParkingLot] {
        parkingLots.filter { !$0.isOpen || $0.availableSpots == 0 }
    }

    var body: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            if !openLots.isEmpty {
                Section("Available") {
                    ForEach(openLots) { lot in
                        Button {
                            selectedLot = lot
                        } label: {
                            ParkingLotRow(lot: lot)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !fullLots.isEmpty {
                Section("Full or Closed") {
                    ForEach(fullLots) { lot in
                        Button {
                            selectedLot = lot
                        } label: {
                            ParkingLotRow(lot: lot)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Parking")
        .sheet(item: $selectedLot) { lot in
            ParkingLotDetailSheet(lot: lot)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "parkingsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.green.gradient, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Campus Parking")
                        .font(.headline)
                    Text("\(data?.availableSpotsCount ?? 0) total spots available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                LiveBadge()
            }

            if let best = data?.bestLot {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("Best: \(best.name) (\(best.availableSpots) spots)")
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

// MARK: - Parking Lot Row

private struct ParkingLotRow: View {
    let lot: ParkingLot

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(lot.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(lot.availableSpots > 0 ? .primary : .secondary)

                HStack(spacing: 8) {
                    Text(lot.statusText)
                        .font(.caption)
                        .foregroundStyle(statusColor)

                    if let detail = lot.detail {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            CapacityBar(value: lot.occupancy)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch lot.occupancy {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }
}

// MARK: - Capacity Bar

private struct CapacityBar: View {
    let value: Double

    private var color: Color {
        switch value {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary)
                .frame(width: 50, height: 6)

            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 50 * min(value, 1.0), height: 6)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Parking Lot Detail Sheet

private struct ParkingLotDetailSheet: View {
    let lot: ParkingLot
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "parkingsign.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(lot.name)
                                    .font(.headline)
                                Text(lot.statusText)
                                    .font(.subheadline)
                                    .foregroundStyle(statusColor)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Occupancy")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.quaternary)

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(statusColor)
                                        .frame(width: geometry.size.width * min(lot.occupancy, 1.0))
                                }
                            }
                            .frame(height: 12)

                            Text("\(Int(lot.occupancy * 100))% full • \(lot.availableSpots) of \(lot.totalSpots) available")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Details") {
                    if let detail = lot.detail {
                        LabeledContent("Info", value: detail)
                    }
                    LabeledContent("Total Capacity", value: "\(lot.totalSpots) spots")
                    LabeledContent("Status", value: lot.isOpen ? "Open" : "Closed")
                }

                Section {
                    Button {
                        // Future: Set as favorite
                    } label: {
                        Label("Set as Favorite", systemImage: "star")
                    }

                    Button {
                        // Future: Open in Maps
                    } label: {
                        Label("Get Directions", systemImage: "map")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(lot.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var statusColor: Color {
        switch lot.occupancy {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    ParkingDetailView(data: nil)
}
