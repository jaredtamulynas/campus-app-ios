//
//  CampusAppApp.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/2/25.
//

import SwiftUI

@main
struct CampusAppApp: App {
    @State private var campusManager = CampusManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(campusManager)
        }
    }
}
