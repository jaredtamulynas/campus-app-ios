//
//  AccountView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/28/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(UserSettings.self) private var userSettings
    @Environment(CampusManager.self) private var campusManager

    @State private var viewModel = AccountViewModel()
    @State private var showingMessages = false
    @State private var showingPerspectiveSelection = false

    var body: some View {
        NavigationStack {
            LoadStateView(state: viewModel.state, retry: { await viewModel.loadAccountData() }) {
                List {
                    perspectiveSection
                    messagesSection
                    permissionsSection
                    aboutSection
                    appSection
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Account")
            .task { await viewModel.loadAccountData() }
            .refreshable { await viewModel.loadAccountData() }
            .sheet(isPresented: $showingMessages) {
                MessagesView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingPerspectiveSelection) {
                PerspectiveSelectionView()
            }
        }
    }

    // MARK: - Perspective Section

    private var perspectiveSection: some View {
        Section {
            Button { showingPerspectiveSelection = true } label: {
                HStack(spacing: 16) {
                    perspectiveIcon
                    perspectiveInfo
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Perspective: \(userSettings.selectedPerspective?.displayInfo.title ?? "Not selected")")
            .accessibilityHint("Double tap to change")
        }
    }

    private var perspectiveIcon: some View {
        Image(systemName: userSettings.selectedPerspective?.displayInfo.systemImage ?? "person.fill")
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: 50, height: 50)
            .background(.accent.gradient, in: Circle())
    }

    private var perspectiveInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(userSettings.selectedPerspective?.displayInfo.title ?? "Welcome")
                .font(.headline)
            Text("Tap to change perspective")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Messages Section

    private var messagesSection: some View {
        Section {
            Button { showingMessages = true } label: {
                HStack {
                    Label("Messages", systemImage: "bell.fill")
                    Spacer()
                    if viewModel.unreadCount > 0 {
                        Text("\(viewModel.unreadCount)")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.red, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Messages")
            .accessibilityValue(viewModel.unreadCount > 0 ? "\(viewModel.unreadCount) unread" : "No unread messages")
        }
    }

    // MARK: - Permissions Section

    private var permissionsSection: some View {
        Section("Settings") {
            NavigationLink {
                NotificationSettingsView()
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications")
                        Text("WolfAlerts and updates")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.red)
                }
            }

            NavigationLink {
                LocationSettingsView()
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Location")
                        Text("Campus navigation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
    }

    // MARK: - About Section

    @ViewBuilder
    private var aboutSection: some View {
        let aboutItems = viewModel.sections.first { $0.id == "about-support" }?.items ?? []

        if !aboutItems.isEmpty {
            Section("About & Support") {
                ForEach(aboutItems) { item in
                    NavigatableRow(item: item)
                }
            }
        }
    }

    // MARK: - App Section

    private var appSection: some View {
        Section {
            if let appStoreURL = campusManager.config.appStoreURL,
               let url = URL(string: appStoreURL) {
                ShareLink(item: url) {
                    Label("Share App", systemImage: "square.and.arrow.up")
                }
            }

            LabeledContent("Version", value: appVersion)
                .foregroundStyle(.secondary)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    AccountView()
        .environment(UserSettings())
        .environment(CampusManager())
}
