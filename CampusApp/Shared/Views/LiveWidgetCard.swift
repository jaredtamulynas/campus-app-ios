//
//  LiveWidgetCard.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import SwiftUI

// MARK: - Live Widget Card

/// A compact, wide widget card for displaying live campus data.
/// Horizontal layout optimized for showing key data at a glance.
struct LiveWidgetCard: View {
    let display: LiveWidgetDisplay
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Left: Icon
                Image(systemName: display.type.icon)
                    .font(.title2)
                    .foregroundStyle(display.type.accentColor)
                    .frame(width: 32)

                // Center: Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(display.type.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(display.primaryLabel)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 4)

                // Right: Value + indicator
                if display.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(display.primaryValue)
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            if let label = display.secondaryLabel {
                                Text(label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let accent = display.accentValue {
                            compactProgressBar(value: accent)
                        } else if let secondary = display.secondaryValue {
                            Text(secondary)
                                .font(.caption2)
                                .foregroundStyle(statusColor(for: secondary))
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func compactProgressBar(value: Double) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.quaternary)
                .frame(width: 50, height: 4)

            RoundedRectangle(cornerRadius: 2)
                .fill(progressColor(for: value))
                .frame(width: 50 * min(max(value, 0), 1), height: 4)
        }
    }

    private func progressColor(for value: Double) -> Color {
        switch value {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }

    private func statusColor(for status: String?) -> Color {
        guard let status = status?.lowercased() else { return .secondary }
        if status.contains("delay") { return .orange }
        if status.contains("on time") { return .green }
        return .secondary
    }
}

// MARK: - Adaptive Live Widgets Grid

/// An adaptive grid for live widgets.
/// Uses adaptive columns: single column on narrow screens, multiple on wider screens.
struct AdaptiveLiveWidgetsView: View {
    let widgets: [LiveWidgetDisplay]
    let onWidgetTap: (LiveWidgetType) -> Void

    // Adaptive columns with minimum width
    // - Narrow (iPhone portrait): 1 column (min 280 fills screen)
    // - Medium (iPhone landscape): 2 columns
    // - Wide (iPad): 2-3+ columns
    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 500), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(widgets) { widget in
                LiveWidgetCard(
                    display: widget,
                    onTap: { onWidgetTap(widget.type) }
                )
            }
        }
    }
}

// MARK: - Legacy Support

extension LiveWidgetCard {
    init(
        data: LiveWidgetData,
        size: LiveWidgetSize = .small,
        onTap: (() -> Void)? = nil,
        onAdd: (() -> Void)? = nil
    ) {
        self.display = LiveWidgetDisplay(
            type: data.type,
            primaryLabel: data.primaryValue ?? data.title,
            primaryValue: data.secondaryValue?.components(separatedBy: " ").first ?? "--",
            secondaryLabel: data.secondaryValue?.components(separatedBy: " ").dropFirst().joined(separator: " "),
            secondaryValue: nil,
            accentValue: data.items.first?.capacity,
            isLoading: false
        )
        self.onTap = onTap
    }
}

enum LiveWidgetSize {
    case small
    case medium
}

// MARK: - Shimmer Effect

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

// MARK: - Preview

#Preview("Adaptive Grid") {
    ScrollView {
        VStack(spacing: 20) {
            SectionHeader("Live Campus") {
                LiveBadge()
            }

            AdaptiveLiveWidgetsView(
                widgets: [
                    LiveWidgetDisplay(type: .wolfline, primaryLabel: "Route 3 • Wolf Village", primaryValue: "2 min", secondaryLabel: nil, secondaryValue: "On time", accentValue: nil, isLoading: false),
                    LiveWidgetDisplay(type: .parking, primaryLabel: "Dan Allen Deck", primaryValue: "165", secondaryLabel: "spots", secondaryValue: nil, accentValue: 0.35, isLoading: false),
                    LiveWidgetDisplay(type: .dining, primaryLabel: "Fountain Dining", primaryValue: "Not busy", secondaryLabel: nil, secondaryValue: nil, accentValue: 0.32, isLoading: false),
                    LiveWidgetDisplay(type: .recreation, primaryLabel: "Carmichael Gym", primaryValue: "Moderate", secondaryLabel: nil, secondaryValue: nil, accentValue: 0.55, isLoading: false)
                ],
                onWidgetTap: { _ in }
            )
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Single Widget") {
    VStack {
        LiveWidgetCard(
            display: LiveWidgetDisplay(
                type: .parking,
                primaryLabel: "Dan Allen Deck",
                primaryValue: "165",
                secondaryLabel: "spots",
                secondaryValue: nil,
                accentValue: 0.35,
                isLoading: false
            )
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Dark Mode") {
    ScrollView {
        AdaptiveLiveWidgetsView(
            widgets: [
                LiveWidgetDisplay(type: .wolfline, primaryLabel: "Route 3", primaryValue: "2 min", secondaryLabel: nil, secondaryValue: "On time", accentValue: nil, isLoading: false),
                LiveWidgetDisplay(type: .parking, primaryLabel: "Dan Allen", primaryValue: "165", secondaryLabel: "spots", secondaryValue: nil, accentValue: 0.35, isLoading: false)
            ],
            onWidgetTap: { _ in }
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
