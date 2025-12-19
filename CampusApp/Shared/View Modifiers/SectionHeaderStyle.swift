//
//  SectionHeaderStyle.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

// MARK: - Section Header Style Modifier

/// Applies consistent section header styling
struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}

// MARK: - List Section Header

/// A reusable List section header with optional trailing accessory
struct ListSectionHeader<Accessory: View>: View {
    let title: String
    @ViewBuilder let accessory: () -> Accessory

    init(_ title: String, @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }) {
        self.title = title
        self.accessory = accessory
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            accessory()
                .font(.caption)
                .foregroundStyle(.accent)
        }
        .sectionHeaderStyle()
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Reusable Accessory Views

/// "Clear" button accessory for section headers
struct ClearAccessory: View {
    let action: () -> Void

    var body: some View {
        Button("Clear", action: action)
            .accessibilityLabel("Clear all")
            .accessibilityHint("Removes all items from this section")
    }
}

/// "See All" navigation link accessory for section headers
struct SeeAllAccessory<Destination: View>: View {
    @ViewBuilder let destination: () -> Destination

    init(@ViewBuilder destination: @escaping () -> Destination) {
        self.destination = destination
    }

    var body: some View {
        NavigationLink("See All", destination: destination)
            .accessibilityLabel("See all items")
            .accessibilityHint("Shows complete list")
    }
}

/// Count badge accessory for section headers
struct CountAccessory: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.quaternary, in: Capsule())
            .accessibilityLabel("\(count) items")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        List {
            Section {
                Text("Content")
            } header: {
                ListSectionHeader("Recently Viewed") {
                    ClearAccessory { }
                }
            }

            Section {
                Text("Content")
            } header: {
                ListSectionHeader("Favorites") {
                    SeeAllAccessory { Text("All Favorites") }
                }
            }

            Section {
                Text("Content")
            } header: {
                ListSectionHeader("Resources") {
                    CountAccessory(count: 42)
                }
            }
        }
    }
}
