//
//  EventDetailSheet.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct EventDetailSheet: View {
    let event: CampusEvent
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(event.category.rawValue.capitalized, systemImage: event.category.icon)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(event.category.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(event.category.color.opacity(0.12), in: Capsule())

                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(event.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
                }

                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.formattedDate)
                            if let endDate = event.endDate {
                                Text("Until \(endDate.formatted(.dateTime.hour().minute()))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                    }

                    Label {
                        Text(event.location)
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        // Add to calendar
                    } label: {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
                    }

                    Button {
                        // Get directions
                    } label: {
                        Label("Get Directions", systemImage: "map")
                    }

                    Button {
                        // Share
                    } label: {
                        Label("Share Event", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Event Details")
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

#Preview {
    EventDetailSheet(
        event: CampusEvent(
            id: "1",
            title: "Football vs Duke",
            subtitle: "ACC Conference Game",
            date: Date(),
            endDate: Date().addingTimeInterval(3600 * 3),
            location: "Carter-Finley Stadium",
            category: .athletics,
            imageURL: nil,
            url: nil
        )
    )
}
