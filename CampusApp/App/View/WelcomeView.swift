//
//  WelcomeView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(CampusManager.self) private var campusManager

    var body: some View {
        VStack(spacing: 12) {
            GIFView(name: "launchImage")
                .frame(width: 200, height: 200)
                .aspectRatio(contentMode: .fit)
                
            Text(campusManager.config.displayName)
                .font(.largeTitle.bold())

            Text("Welcome to the Pack")
                .font(.headline)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(CampusManager.shared)
}
