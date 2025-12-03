//
//  ContentView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(CampusManager.self) private var campusManager

    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                WelcomeView()
                    .transition(.opacity)
            } else if false {
                PerspectiveSelectionView()
            } else {
                MainTabView()
            }
        }
        .task {
            // Simulate splash delay
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(CampusManager.shared)
}
