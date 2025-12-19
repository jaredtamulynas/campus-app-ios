//
//  EventsListView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct EventsListView: View {
    let events: [CampusEvent]

    var body: some View {
        List(events) { event in
            EventListRow(event: event)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Upcoming Events")
    }
}

// MARK: - Event List Row

struct EventListRow: View {
    let event: CampusEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(event.category.rawValue.capitalized, systemImage: event.category.icon)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(event.category.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(event.category.color.opacity(0.12), in: Capsule())

                Spacer()

                Text(event.shortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(event.title)
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                Label(event.timeString, systemImage: "clock")
                Label(event.location, systemImage: "mappin")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        EventsListView(events: [
            CampusEvent(
                id: "1",
                title: "Football vs Duke",
                subtitle: "ACC Conference Game",
                date: Date(),
                endDate: nil,
                location: "Carter-Finley Stadium",
                category: .athletics,
                imageURL: nil,
                url: nil
            ),
            CampusEvent(
                id: "2",
                title: "Career Fair",
                subtitle: "Engineering Career Fair",
                date: Date().addingTimeInterval(86400),
                endDate: nil,
                location: "Talley Student Union",
                category: .career,
                imageURL: nil,
                url: nil
            )
        ])
    }
}
