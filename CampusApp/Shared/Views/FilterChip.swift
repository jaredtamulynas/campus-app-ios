//
//  FilterChip.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/24/25.
//

import SwiftUI

/// A filter chip for category selection
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    var badgeCount: Int? = nil
    let action: () -> Void
    
    @ScaledMetric(relativeTo: .subheadline) private var horizontalPadding: CGFloat = 12
    @ScaledMetric(relativeTo: .subheadline) private var verticalPadding: CGFloat = 6
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                        .accessibilityHidden(true)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fixedSize(horizontal: true, vertical: false)
                
                if let badgeCount, badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .background(.secondary.opacity(0.3), in: Capsule())
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color(.tertiaryLabel), lineWidth: 0.5)
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
    
    private var accessibilityLabel: String {
        var label = title
        if let badgeCount, badgeCount > 0 {
            label += ", \(badgeCount) items"
        }
        return label
    }
}

#Preview("Light Mode") {
    HStack {
        FilterChip(title: "All", isSelected: true, action: {})
        FilterChip(title: "Category", icon: "folder", isSelected: false, action: {})
        FilterChip(title: "Unread", isSelected: false, badgeCount: 5, action: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Dark Mode") {
    HStack {
        FilterChip(title: "All", isSelected: true, action: {})
        FilterChip(title: "Category", icon: "folder", isSelected: false, action: {})
        FilterChip(title: "Unread", isSelected: false, badgeCount: 5, action: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    HStack {
        FilterChip(title: "All", isSelected: true, action: {})
        FilterChip(title: "Category", isSelected: false, action: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .dynamicTypeSize(.accessibility1)
}
