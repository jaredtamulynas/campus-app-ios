//
//  ContentView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(CampusManager.self) private var campusManager
    @Environment(UserSettings.self) private var userSettings

    @State private var showSplash = true
    @State private var isDataLoaded = false
    @State private var weatherViewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            if showSplash {
                WelcomeView()
                    .transition(.opacity)
            } else if !userSettings.hasSelection {
                PerspectiveSelectionView()
            } else {
                MainTabView()
                    .environment(weatherViewModel)
            }
        }
        .task {
            await preloadData()
        }
    }
    
    /// Preload essential data during splash screen
    private func preloadData() async {
        // Start minimum display time and data loading in parallel
        async let minimumDelay: () = Task.sleep(for: .seconds(1))
        async let dataLoading: () = loadEssentialData()
        
        // Wait for both minimum time AND data to be ready
        _ = try? await (minimumDelay, dataLoading)
        
        // Dismiss splash
        withAnimation(.easeOut(duration: 1.0)) {
            showSplash = false
        }
    }
    
    /// Load data that should be ready before showing the app
    private func loadEssentialData() async {
        // Start observing weather (Firebase realtime)
        weatherViewModel.startObserving()
        
        // Add other preloading here:
        // - await loadResources()
        // - await loadGuides()
        // - startObservingAlerts()
        // - etc.
        
        // Give observers a moment to receive initial data
        try? await Task.sleep(for: .milliseconds(500))
        
        isDataLoaded = true
    }
}

#Preview {
    ContentView()
        .environment(CampusManager())
        .environment(UserSettings())
}
