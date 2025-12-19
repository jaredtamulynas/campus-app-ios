//
//  PermissionCard.swift
//  CampusApp
//
//  Created by Claude Code on 12/18/25.
//

import SwiftUI

// MARK: - Permission State

enum PermissionState {
    case notDetermined
    case authorized
    case denied
}

// MARK: - Permission Card

struct PermissionCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let state: PermissionState
    let onEnable: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        switch state {
        case .notDetermined:
            promptCard
        case .authorized:
            enabledCard
        case .denied:
            deniedCard
        }
    }

    private var promptCard: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(color.gradient)

            VStack(spacing: 8) {
                Text("Enable \(title)")
                    .font(.title3.weight(.semibold))
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onEnable) {
                Text("Enable \(title)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Enable \(title)")
        .accessibilityHint(description)
    }

    private var enabledCard: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("\(title) Enabled")
                .fontWeight(.medium)
        }
        .accessibilityLabel("\(title) is enabled")
    }

    private var deniedCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "\(icon.replacingOccurrences(of: ".fill", with: "")).slash.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("\(title) Disabled")
                    .font(.title3.weight(.semibold))
                Text("Enable \(title.lowercased()) in Settings to use this feature")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onOpenSettings) {
                HStack {
                    Image(systemName: "gear")
                    Text("Open Settings")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) is disabled")
        .accessibilityHint("Tap to open Settings")
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
    }
}

// MARK: - Preview

#Preview {
    List {
        Section {
            PermissionCard(
                icon: "bell.circle.fill",
                color: .red,
                title: "Notifications",
                description: "Stay informed about campus emergencies and events",
                state: .notDetermined,
                onEnable: {},
                onOpenSettings: {}
            )
        }
        .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))

        Section("Status") {
            PermissionCard(
                icon: "bell.circle.fill",
                color: .red,
                title: "Notifications",
                description: "",
                state: .authorized,
                onEnable: {},
                onOpenSettings: {}
            )
        }

        Section("Features") {
            FeatureRow(
                icon: "map.fill",
                color: .blue,
                title: "Campus Navigation",
                description: "Get directions to buildings and parking"
            )
        }
    }
}
