//
//  GuidesGridView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/3/25.
//

import SwiftUI

// MARK: - Guides Grid View

struct GuidesGridView: View {
    @Environment(UserSettings.self) private var userSettings
    let guides: [Guide]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(guides) { guide in
                NavigationLink(value: guide) {
                    GuideCard(
                        guide: guide,
                        isStarted: userSettings.isGuideStarted(guide.id),
                        completedTodos: userSettings.completedTodoCount(
                            for: guide.id,
                            totalTodos: guide.todos?.count ?? 0
                        ),
                        totalTodos: guide.todos?.count ?? 0
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Horizontal Guides Scroll

struct HorizontalGuidesScroll: View {
    @Environment(UserSettings.self) private var userSettings
    let guides: [Guide]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(guides) { guide in
                    NavigationLink(value: guide) {
                        GuideCard(
                            guide: guide,
                            isStarted: userSettings.isGuideStarted(guide.id),
                            completedTodos: userSettings.completedTodoCount(
                                for: guide.id,
                                totalTodos: guide.todos?.count ?? 0
                            ),
                            totalTodos: guide.todos?.count ?? 0,
                            style: .horizontal
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Guide Card

struct GuideCard: View {
    let guide: Guide
    let isStarted: Bool
    let completedTodos: Int
    let totalTodos: Int
    var style: CardStyle = .grid
    
    enum CardStyle {
        case grid
        case horizontal
    }
    
    private var guideColor: Color {
        colorForName(guide.color)
    }
    
    private var allTodosComplete: Bool {
        totalTodos > 0 && completedTodos >= totalTodos
    }
    
    private var todoProgress: Double {
        guard totalTodos > 0 else { return 0 }
        return Double(completedTodos) / Double(totalTodos)
    }
    
    private var cardHeight: CGFloat {
        style == .grid ? 180 : 160
    }
    
    private var cardWidth: CGFloat? {
        style == .horizontal ? 220 : nil
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image
            imageBackground
            
            // Material overlay with content
            VStack(alignment: .leading, spacing: 6) {
                // Alert badge at top
                if let alert = guide.alert {
                    HStack {
                        AlertBadge(alert: alert)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Bottom content with material background
                VStack(alignment: .leading, spacing: 8) {
                    // Title and department
                    VStack(alignment: .leading, spacing: 2) {
                        Text(guide.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        
                        Text(guide.department)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    // Progress or content summary
                    HStack(spacing: 8) {
                        if allTodosComplete && totalTodos > 0 {
                            Label("Complete", systemImage: "checkmark.circle.fill")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.green)
                        } else if totalTodos > 0 {
                            ProgressView(value: todoProgress)
                                .tint(guideColor)
                            
                            Text("\(completedTodos)/\(totalTodos)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        } else {
                            // Show content summary
                            contentSummary
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16))
            }
            .padding(.top, 10)
        }
        .frame(height: cardHeight)
        .frame(width: cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var contentSummary: some View {
        let eventCount = guide.events?.count ?? 0
        let sectionCount = guide.sections?.count ?? 0
        
        HStack(spacing: 12) {
            if eventCount > 0 {
                Label("\(eventCount)", systemImage: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if sectionCount > 0 {
                Label("\(sectionCount)", systemImage: "doc.text")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if eventCount == 0 && sectionCount == 0 {
                Image(systemName: guide.icon)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var imageBackground: some View {
        if let imageUrl = guide.headerImageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    fallbackBackground
                case .empty:
                    fallbackBackground
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }
                @unknown default:
                    fallbackBackground
                }
            }
        } else {
            fallbackBackground
        }
    }
    
    private var fallbackBackground: some View {
        ZStack {
            LinearGradient(
                colors: [guideColor.opacity(0.8), guideColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: guide.icon)
                .font(.system(size: 50))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "teal": return .teal
        case "mint": return .mint
        default: return .blue
        }
    }
}

// MARK: - Alert Badge

private struct AlertBadge: View {
    let alert: GuideAlert
    
    private var color: Color {
        colorForName(alert.type.color)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: alert.type.icon)
                .font(.caption2)
            
            Text(alert.message)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color, in: Capsule())
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var settings = UserSettings()
    
    NavigationStack {
        ScrollView {
            VStack(spacing: 24) {
                // Horizontal scroll
                VStack(alignment: .leading, spacing: 12) {
                    Text("Featured")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HorizontalGuidesScroll(guides: previewGuides.filter { $0.isFeatured })
                }
                
                // Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Guides")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    GuidesGridView(guides: previewGuides)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
    .environment(settings)
}

private let previewGuides = [
    Guide(
        id: "1",
        title: "Wolfpack Welcome Week",
        department: "Student Affairs",
        description: "Everything you need",
        headerImageUrl: "https://www.ncsu.edu/wp-content/uploads/2019/06/belltower-spring-2019.jpg",
        icon: "party.popper.fill",
        color: "red",
        visibility: .all,
        featured: true,
        alert: GuideAlert(type: .new, message: "Starts Aug 14!"),
        sections: nil,
        events: [
            GuideEvent(id: "e1", title: "Event", description: nil, category: .orientation, startDate: "2025-08-14", endDate: nil, location: nil, locationId: nil, isRequired: nil)
        ],
        locations: nil,
        todos: [
            GuideTodo(id: "t1", title: "Task 1", description: nil, dueDate: nil, priority: nil, category: nil, linkedUrl: nil),
            GuideTodo(id: "t2", title: "Task 2", description: nil, dueDate: nil, priority: nil, category: nil, linkedUrl: nil)
        ],
        faqs: nil,
        contacts: nil,
        links: nil,
        updates: nil
    ),
    Guide(
        id: "2",
        title: "Campus Safety",
        department: "Campus Police",
        description: "Stay safe",
        headerImageUrl: nil,
        icon: "shield.fill",
        color: "blue",
        visibility: .all,
        featured: nil,
        alert: GuideAlert(type: .info, message: "Essential"),
        sections: nil,
        events: nil,
        locations: nil,
        todos: nil,
        faqs: nil,
        contacts: nil,
        links: nil,
        updates: nil
    ),
    Guide(
        id: "3",
        title: "Housing Move-In",
        department: "Housing",
        description: "Checklist",
        headerImageUrl: "https://live.staticflickr.com/65535/52519826344_c7b0e7b0e7_k.jpg",
        icon: "house.fill",
        color: "green",
        visibility: .all,
        featured: true,
        alert: GuideAlert(type: .action, message: "Action Required"),
        sections: nil,
        events: nil,
        locations: nil,
        todos: [
            GuideTodo(id: "t1", title: "Task 1", description: nil, dueDate: nil, priority: nil, category: nil, linkedUrl: nil),
            GuideTodo(id: "t2", title: "Task 2", description: nil, dueDate: nil, priority: nil, category: nil, linkedUrl: nil),
            GuideTodo(id: "t3", title: "Task 3", description: nil, dueDate: nil, priority: nil, category: nil, linkedUrl: nil)
        ],
        faqs: nil,
        contacts: nil,
        links: nil,
        updates: nil
    )
]
