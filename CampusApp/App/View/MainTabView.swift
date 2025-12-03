//
//  MainTabView.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
//            Tab("Home", systemImage: "house.fill") {
//                HomeView()
//            }
//            
//            // Campus Map - visible to all
//            Tab("Campus", systemImage: "map.fill") {
//                CampusView()
//            }
            
            // Resources tab - visible to all
            Tab("Resources", systemImage: "list.bullet") {
                Text("Resources")
            }
            
//            // Guides tab - visible to all
//            Tab("Guides", systemImage: "book.fill") {
//                GuidesView()
//            }
//            
//            // Account tab - visible to all
//            Tab("Account", systemImage: "person.crop.circle") {
//                AccountView()
//            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(CampusManager.shared)
}
