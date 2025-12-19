//
//  ContentCard.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/26/25.
//

import SwiftUI

// MARK: - Content Card

/// A standardized card component used across all views
/// Provides consistent styling for guides, resources, events, and live status
struct ContentCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Icon Card

/// A card with a prominent icon, title, and optional subtitle
/// Used for guides, quick actions, and category cards
struct IconCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    var showChevron: Bool = false
    
    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 44
    
    var body: some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
                    .background(iconColor.opacity(0.15), in: Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if showChevron {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

// MARK: - Live Status Card

/// A compact card for displaying live data (bus, parking, dining, etc.)
struct LiveCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var detail: String? = nil
    var isLive: Bool = true
    
    @ScaledMetric(relativeTo: .body) private var minWidth: CGFloat = 130
    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                
                Spacer()
                
                if isLive {
                    LiveBadge()
                }
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(minWidth: minWidth, minHeight: minHeight)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Event Card

/// A card for displaying events in horizontal carousels
struct EventCard: View {
    let title: String
    let date: String
    let location: String
    let icon: String
    let color: Color
    
    @ScaledMetric(relativeTo: .body) private var minWidth: CGFloat = 150
    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Spacer(minLength: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label(location, systemImage: "mappin")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .frame(minWidth: minWidth, minHeight: minHeight)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Quick Action

/// A compact action button for grids
struct QuickAction: View {
    let icon: String
    let title: String
    let color: Color
    
    @ScaledMetric(relativeTo: .body) private var iconFrameSize: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: iconFrameSize, height: iconFrameSize)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Live Badge

/// A small indicator showing live status
struct LiveBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.red)
                .frame(width: 6, height: 6)
            Text("LIVE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.red)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Live")
    }
}

// MARK: - Busyness Row

/// A row showing location busyness level
struct BusynessRow: View {
    let location: String
    let level: Double
    
    private var levelColor: Color {
        if level < 0.4 { return .green }
        if level < 0.7 { return .orange }
        return .red
    }
    
    private var levelText: String {
        if level < 0.4 { return "Not busy" }
        if level < 0.7 { return "Moderate" }
        return "Very busy"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(location)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(levelText)
                    .font(.caption)
                    .foregroundStyle(levelColor)
            }
            
            Spacer()
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.quaternary)
                    .frame(width: 60, height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(levelColor)
                    .frame(width: 60 * level, height: 6)
            }
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(location), \(levelText)")
    }
}

// MARK: - Compact Card

/// A small card for horizontal scroll sections (favorites, recent)
/// Handles navigation the same way as NavigatableRow
struct CompactCard<Item: NavigatableItem>: View {
    let item: Item
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    
    @State private var showingSheet = false
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .body) private var minWidth: CGFloat = 100
    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 80
    
    var body: some View {
        Group {
            switch item.navigationType {
            case .link, .action:
                Button {
                    onTap?()
                    handleAction()
                } label: { cardContent }
                    .accessibilityHint("Opens in browser")
                
            case .navigation:
                if let viewBuilder = item.navigationDestination.viewBuilder {
                    NavigationLink {
                        viewBuilder()
                            .onAppear { onTap?() }
                    } label: { cardContent }
                } else {
                    cardContent
                }
                
            case .sheet:
                Button {
                    onTap?()
                    showingSheet = true
                } label: { cardContent }
                    .sheet(isPresented: $showingSheet) { sheetContent }
                    .accessibilityHint("Opens details")
                
            case .none:
                cardContent
            }
        }
        .buttonStyle(.plain)
    }
    
    private var cardContent: some View {
        VStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundStyle(item.iconColor)
            
            Text(item.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: minWidth, minHeight: minHeight)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(.isButton)
    }
    
    @ViewBuilder
    private var sheetContent: some View {
        if let contactInfo = item.navigationDestination.contactInfo,
           let resource = item as? Resource {
            ResourceContactSheet(resource: resource, contactInfo: contactInfo)
        } else if let urlString = item.navigationDestination.url,
                  let url = URL(string: urlString) {
            WebViewSheet(url: url, title: item.title)
        } else if let viewBuilder = item.navigationDestination.viewBuilder {
            viewBuilder()
        }
    }
    
    private func handleAction() {
        if let urlString = item.navigationDestination.url,
           let url = URL(string: urlString) {
            openURL(url)
        }
    }
}

// MARK: - Previews

#Preview("Icon Card - Light") {
    IconCard(
        icon: "graduationcap.fill",
        iconColor: .red,
        title: "New Student Orientation",
        subtitle: "Student Affairs"
    )
    .frame(width: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Icon Card - Dark") {
    IconCard(
        icon: "graduationcap.fill",
        iconColor: .red,
        title: "New Student Orientation",
        subtitle: "Student Affairs"
    )
    .frame(width: 180)
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}

#Preview("Icon Card - Large Text") {
    IconCard(
        icon: "graduationcap.fill",
        iconColor: .red,
        title: "New Student Orientation",
        subtitle: "Student Affairs"
    )
    .frame(width: 200)
    .padding()
    .background(Color(.systemGroupedBackground))
    .dynamicTypeSize(.accessibility3)
}

#Preview("Live Card") {
    HStack {
        LiveCard(
            icon: "bus.fill",
            iconColor: .blue,
            title: "Wolfline",
            value: "3 routes",
            detail: "Next: 2 min"
        )
        
        LiveCard(
            icon: "parkingsign.circle.fill",
            iconColor: .green,
            title: "Parking",
            value: "Dan Allen: 45",
            detail: "Coliseum: 120"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Event Card") {
    EventCard(
        title: "Football vs. Duke",
        date: "Saturday, 3:30 PM",
        location: "Carter-Finley Stadium",
        icon: "sportscourt.fill",
        color: .red
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Card - Light") {
    HStack {
        CompactCard(item: PreviewNavigatableItem(
            title: "WolfPack One Card",
            icon: "creditcard.fill",
            iconColor: .green,
            url: "https://onecard.ncsu.edu"
        ))
        
        CompactCard(item: PreviewNavigatableItem(
            title: "Wolfline Bus",
            icon: "bus.fill",
            iconColor: .blue,
            url: "https://transportation.ncsu.edu"
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Card - Dark") {
    HStack {
        CompactCard(item: PreviewNavigatableItem(
            title: "WolfPack One Card",
            icon: "creditcard.fill",
            iconColor: .green,
            url: "https://onecard.ncsu.edu"
        ))
        
        CompactCard(item: PreviewNavigatableItem(
            title: "Wolfline Bus",
            icon: "bus.fill",
            iconColor: .blue,
            url: "https://transportation.ncsu.edu"
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}

#Preview("Compact Card - Large Text") {
    HStack {
        CompactCard(item: PreviewNavigatableItem(
            title: "WolfPack One Card",
            icon: "creditcard.fill",
            iconColor: .green,
            url: "https://onecard.ncsu.edu"
        ))
        
        CompactCard(item: PreviewNavigatableItem(
            title: "Wolfline Bus",
            icon: "bus.fill",
            iconColor: .blue,
            url: "https://transportation.ncsu.edu"
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .dynamicTypeSize(.accessibility1)
}

// MARK: - Preview Helper

private struct PreviewNavigatableItem: NavigatableItem {
    let id = UUID()
    let title: String
    var subtitle: String? = nil
    let icon: String
    let iconColor: Color
    var url: String? = nil
    
    var navigationType: NavigationType {
        url != nil ? .link : .none
    }
    
    var navigationDestination: NavigationDestination {
        NavigationDestination(url: url)
    }
}
