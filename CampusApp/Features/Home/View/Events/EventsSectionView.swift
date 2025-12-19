//
//  EventsSectionView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct EventsSectionView: View {
    let events: [CampusEvent]
    let onEventTap: (CampusEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Upcoming Events") {
                SeeAllAccessory { EventsListView(events: events) }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(events) { event in
                        CampusEventCard(event: event)
                            .containerRelativeFrame(.horizontal, count: 5, span: 3, spacing: 12)
                            .onTapGesture { onEventTap(event) }
                            .accessibilityLabel(event.title)
                            .accessibilityHint("Double tap to view details")
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16)
            .scrollTargetBehavior(.viewAligned)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Upcoming events, \(events.count) events")
        }
    }
}

#Preview {
    EventsSectionView(
        events: [
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
            )
        ],
        onEventTap: { _ in }
    )
}
