//
//  SectionView.swift
//  CampusApp
//
//  Created by Claude Code on 12/15/25.
//

import SwiftUI

// MARK: - Section View

/// A reusable section container for ScrollView contexts (not List).
/// Use for consistent section styling on Home and similar screens.
struct SectionView<Content: View>: View {
    let header: String?
    let footer: String?
    @ViewBuilder let content: () -> Content

    init(
        _ header: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header {
                Text(header)
                    .sectionHeaderStyle()
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)
            }

            content()
                .padding(.horizontal, 16)

            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 20)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Section Header with Accessory

/// A section header row with optional trailing accessory (button, link, etc.)
/// For use in ScrollView contexts (Home screen sections).
struct SectionHeader<Accessory: View>: View {
    let title: String
    @ViewBuilder let accessory: () -> Accessory

    init(_ title: String, @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }) {
        self.title = title
        self.accessory = accessory
    }

    var body: some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()
                .accessibilityAddTraits(.isHeader)
            Spacer()
            accessory()
                .font(.caption)
                .foregroundStyle(.accent)
        }
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Convenience Extensions

extension SectionView where Content == EmptyView {
    init(_ header: String? = nil, footer: String? = nil) {
        self.header = header
        self.footer = footer
        self.content = { EmptyView() }
    }
}

// MARK: - Preview

#Preview("Section Views") {
    ScrollView {
        VStack(spacing: 24) {
            SectionView("Live Campus") {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .frame(height: 100)
            }

            SectionView("Events", footer: "Swipe to see more events") {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .frame(height: 100)
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionHeader("Featured") {
                    SeeAllAccessory { Text("All Featured") }
                }

                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .frame(height: 100)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}
