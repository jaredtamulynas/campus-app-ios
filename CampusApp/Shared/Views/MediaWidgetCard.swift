//
//  MediaWidgetCard.swift
//  CampusApp
//
//  Created by Claude Code on 12/15/25.
//

import SwiftUI

// MARK: - Media Widget Type

enum MediaWidgetType {
    case radio
    case tv

    var title: String {
        switch self {
        case .radio: return "Radio"
        case .tv: return "TV"
        }
    }

    var icon: String {
        switch self {
        case .radio: return "radio.fill"
        case .tv: return "play.tv.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .radio: return .red
        case .tv: return .blue
        }
    }
}

// MARK: - Media Widget Card

/// A compact, wide widget card for media (Radio/TV).
/// Horizontal layout matching LiveWidgetCard style.
struct MediaWidgetCard: View {
    let type: MediaWidgetType
    let title: String
    let subtitle: String
    let isPlaying: Bool
    let isLoading: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Left: Play button
                playButton

                // Center: Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 4)

                // Right: Status
                VStack(alignment: .trailing, spacing: 4) {
                    if isPlaying {
                        LiveBadge()
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if isPlaying {
                    CompactWaveform()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var playButton: some View {
        ZStack {
            Circle()
                .fill(type.accentColor.gradient)
                .frame(width: 40, height: 40)

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(0.8)
            } else {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(x: isPlaying ? 0 : 1)
            }
        }
    }
}

// MARK: - Compact Waveform

private struct CompactWaveform: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 2, height: animating ? CGFloat.random(in: 8...20) : 8)
                    .animation(
                        .easeInOut(duration: 0.3)
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                        value: animating
                    )
            }
        }
        .frame(width: 16, height: 20)
        .onAppear { animating = true }
    }
}

// MARK: - Audio Waveform Bar (for other uses)

struct AudioWaveformBar: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<12, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 3, height: animating ? CGFloat.random(in: 4...12) : 4)
                    .animation(
                        .easeInOut(duration: 0.3)
                            .repeatForever()
                            .delay(Double(index) * 0.05),
                        value: animating
                    )
            }
            Spacer()
        }
        .frame(height: 12)
        .onAppear { animating = true }
    }
}

// MARK: - Adaptive Media Widgets View

/// An adaptive grid for media widgets.
/// Uses adaptive columns like AdaptiveLiveWidgetsView.
struct AdaptiveMediaWidgetsView: View {
    let radioPlayer: RadioPlayerViewModel
    let onTVTap: () -> Void

    // Adaptive columns - matches live widgets behavior
    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 500), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            RadioWidget(player: radioPlayer)
            TVWidget(onTap: onTVTap)
        }
    }
}

// MARK: - Radio Widget

struct RadioWidget: View {
    let player: RadioPlayerViewModel

    var body: some View {
        MediaWidgetCard(
            type: .radio,
            title: "WolfBytes Radio",
            subtitle: player.isPlaying ? "\(player.currentArtist) • \(player.currentTitle)" : "Student Radio",
            isPlaying: player.isPlaying,
            isLoading: player.isLoading,
            onTap: { player.togglePlayback() }
        )
    }
}

// MARK: - TV Widget

struct TVWidget: View {
    var onTap: () -> Void

    var body: some View {
        MediaWidgetCard(
            type: .tv,
            title: "WolfBytes TV",
            subtitle: "Campus Television",
            isPlaying: false,
            isLoading: false,
            onTap: onTap
        )
    }
}

// MARK: - Preview

#Preview("Adaptive Media") {
    ScrollView {
        VStack(spacing: 20) {
            SectionHeader("Campus Media")

            AdaptiveMediaWidgetsView(
                radioPlayer: RadioPlayerViewModel.shared,
                onTVTap: {}
            )
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Single Widget") {
    VStack(spacing: 12) {
        MediaWidgetCard(
            type: .radio,
            title: "WolfBytes Radio",
            subtitle: "Artist • Song Title",
            isPlaying: true,
            isLoading: false,
            onTap: {}
        )

        MediaWidgetCard(
            type: .tv,
            title: "WolfBytes TV",
            subtitle: "Campus Television",
            isPlaying: false,
            isLoading: false,
            onTap: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Dark Mode") {
    ScrollView {
        AdaptiveMediaWidgetsView(
            radioPlayer: RadioPlayerViewModel.shared,
            onTVTap: {}
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
