//
//  NotificationSettingsView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/30/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var manager = NotificationManager.shared

    private var permissionState: PermissionState {
        switch manager.authorizationStatus {
        case .authorized, .provisional: .authorized
        case .denied: .denied
        default: .notDetermined
        }
    }

    var body: some View {
        List {
            permissionSection
            if permissionState == .authorized {
                topicsSection
                settingsSection
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task { await manager.checkAuthorizationStatus() }
    }

    // MARK: - Sections

    private var permissionSection: some View {
        Section {
            PermissionCard(
                icon: "bell.circle.fill",
                color: .red,
                title: "Notifications",
                description: "Stay informed about campus emergencies, events, and important updates",
                state: permissionState,
                onEnable: {
                    Task { await manager.requestAuthorization() }
                },
                onOpenSettings: manager.openSettings
            )
        }
        .listRowInsets(permissionState == .authorized
            ? nil
            : EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }

    private var topicsSection: some View {
        Section {
            ForEach(NotificationManager.Topic.allCases, id: \.rawValue) { topic in
                TopicToggleRow(
                    topic: topic,
                    isSubscribed: manager.isSubscribed(to: topic),
                    onToggle: { manager.toggleSubscription(for: topic) }
                )
            }
        } header: {
            Text("Topics")
        } footer: {
            Text("WolfAlerts are required for campus safety and cannot be disabled.")
        }
    }

    private var settingsSection: some View {
        Section {
            Button {
                manager.openSettings()
            } label: {
                HStack {
                    Label("Advanced Settings", systemImage: "gear")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Topic Toggle Row

private struct TopicToggleRow: View {
    let topic: NotificationManager.Topic
    let isSubscribed: Bool
    let onToggle: () -> Void

    var body: some View {
        Toggle(isOn: Binding(
            get: { isSubscribed },
            set: { _ in onToggle() }
        )) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.displayName)
                    Text(topic.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: topic.icon)
                    .foregroundStyle(Color(topic.color))
            }
        }
        .disabled(topic.isRequired)
        .tint(Color(topic.color))
        .accessibilityLabel(topic.displayName)
        .accessibilityValue(isSubscribed ? "Subscribed" : "Not subscribed")
        .accessibilityHint(topic.isRequired ? "Required notification" : "Toggle subscription")
    }
}

// MARK: - Color Extension

private extension Color {
    init(_ name: String) {
        switch name {
        case "red": self = .red
        case "blue": self = .blue
        case "green": self = .green
        case "orange": self = .orange
        default: self = .accentColor
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
