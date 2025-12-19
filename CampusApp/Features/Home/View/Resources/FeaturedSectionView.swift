//
//  FeaturedSectionView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct FeaturedSectionView: View {
    let resources: [Resource]
    let isFavorite: (String) -> Bool
    let onFavoriteToggle: (String) -> Void
    let onTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Featured")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(resources) { resource in
                        CompactCard(
                            item: resource,
                            isFavorite: isFavorite(resource.id),
                            onFavoriteToggle: { onFavoriteToggle(resource.id) },
                            onTap: { onTap(resource.id) }
                        )
                        .accessibilityLabel(resource.name)
                        .accessibilityHint("Double tap to open")
                    }
                }
                .padding(.horizontal, 16)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Featured resources, \(resources.count) items")
        }
    }
}

#Preview {
    FeaturedSectionView(
        resources: [],
        isFavorite: { _ in false },
        onFavoriteToggle: { _ in },
        onTap: { _ in }
    )
}
