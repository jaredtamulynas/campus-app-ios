//
//  CampusApp.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI
import FirebaseCore

@main
struct CampusApp: App {
    @State private var campusManager = CampusManager()
    @State private var userSettings = UserSettings()

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(campusManager)
                .environment(userSettings)
        }
    }
}
