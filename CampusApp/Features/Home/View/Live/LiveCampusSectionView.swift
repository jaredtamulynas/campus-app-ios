//
//  LiveCampusSectionView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct LiveCampusSectionView: View {
    let widgets: [LiveWidgetDisplay]
    let onWidgetTap: (LiveWidgetType) -> Void

    var body: some View {
        SectionView("Live Campus") {
            AdaptiveLiveWidgetsView(
                widgets: widgets,
                onWidgetTap: onWidgetTap
            )
        }
    }
}

#Preview {
    LiveCampusSectionView(
        widgets: [
            LiveWidgetDisplay(
                type: .parking,
                primaryLabel: "Dan Allen Deck",
                primaryValue: "165",
                secondaryLabel: "spots open",
                secondaryValue: nil,
                accentValue: 0.35,
                isLoading: false
            )
        ],
        onWidgetTap: { _ in }
    )
}
