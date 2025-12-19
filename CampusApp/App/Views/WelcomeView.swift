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
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                GIFView(name: campusManager.config.id)
                    .frame(width: 250, height: 250)
                    .aspectRatio(contentMode: .fit)
                
                Text(campusManager.config.displayName)
                    .textCase(.uppercase)
                    .font(.title)
                    .bold()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environment(CampusManager())
}
