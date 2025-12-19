//
//  LocationSettingsView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/30/25.
//

import SwiftUI

struct LocationSettingsView: View {
    @State private var manager = LocationManager.shared

    private var permissionState: PermissionState {
        if manager.isAuthorized { .authorized }
        else if manager.isDenied { .denied }
        else { .notDetermined }
    }

    var body: some View {
        List {
            permissionSection
            if permissionState == .authorized {
                featuresSection
                settingsSection
            }
        }
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var permissionSection: some View {
        Section {
            PermissionCard(
                icon: "location.circle.fill",
                color: .blue,
                title: "Location",
                description: "Find nearby dining, parking, buildings, and track Wolfline buses",
                state: permissionState,
                onEnable: manager.requestAuthorization,
                onOpenSettings: manager.openSettings
            )
        }
        .listRowInsets(permissionState == .authorized
            ? nil
            : EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }

    private var featuresSection: some View {
        Section("Features") {
            FeatureRow(
                icon: "map.fill",
                color: .blue,
                title: "Campus Navigation",
                description: "Get directions to buildings, parking, and points of interest"
            )
            FeatureRow(
                icon: "bus.fill",
                color: .green,
                title: "Wolfline Tracking",
                description: "See nearby buses and real-time arrival times"
            )
            FeatureRow(
                icon: "fork.knife",
                color: .orange,
                title: "Nearby Dining",
                description: "Find dining halls and restaurants close to you"
            )
            FeatureRow(
                icon: "car.fill",
                color: .purple,
                title: "Parking Availability",
                description: "Find available parking near your destination"
            )
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

#Preview {
    NavigationStack {
        LocationSettingsView()
    }
}
