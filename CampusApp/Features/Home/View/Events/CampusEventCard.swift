//
//  CampusEventCard.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct CampusEventCard: View {
    let event: CampusEvent

    private var categoryColor: Color {
        event.category.color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category badge
            HStack {
                Label(event.category.rawValue.capitalized, systemImage: event.category.icon)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(categoryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor.opacity(0.12), in: Capsule())

                Spacer()
            }
            .padding(.bottom, 10)

            // Title
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(event.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .padding(.top, 2)

            Spacer(minLength: 8)

            // Date and location
            VStack(alignment: .leading, spacing: 4) {
                Label(event.formattedDate, systemImage: "calendar")
                Label(event.location, systemImage: "mappin")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CampusEventCard(
        event: CampusEvent(
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
    )
    .frame(width: 200)
}
