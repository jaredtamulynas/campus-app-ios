//
//  Resource+NavigatableItem.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/14/25.
//

import SwiftUI

extension Resource: NavigatableItem {
    var title: String {
        name
    }
    
    var subtitle: String? {
        description
    }
    
    var iconColor: Color {
        .accentColor
    }
    
    var navigationType: NavigationType {
        switch type {
        case .externalLink: return .link
        case .sheetCover:   return .sheet
        case .customView:   return .navigation
        case .deepLink:     return .action
        }
    }
    
    var navigationDestination: NavigationDestination {
        NavigationDestination(
            url: destination.url,
            viewIdentifier: destination.viewIdentifier,
            viewBuilder: customViewBuilder,
            contactInfo: contactInfo
        )
    }
    
    private var customViewBuilder: (() -> AnyView)? {
        guard type == .customView,
              let viewIdentifier = destination.viewIdentifier else {
            return nil
        }
        
        return {
            switch viewIdentifier {
            case "WolflineMapView":
                return AnyView(Text("Wolfline Map - Coming Soon").navigationTitle("Wolfline"))
            case "DiningLocationsView":
                return AnyView(Text("Dining Locations - Coming Soon").navigationTitle("Dining"))
            default:
                return AnyView(Text("Unknown View: \(viewIdentifier)"))
            }
        }
    }
}

