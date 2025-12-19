//
//  AccountItem+NavigatableItem.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/14/25.
//

import SwiftUI

extension AccountItem: NavigatableItem {
    var iconColor: Color {
        ColorParser.parse(iconColorName)
    }
    
    var navigationType: NavigationType {
        switch type {
        case .navigationLink:
            return .navigation
        case .externalLink:
            return .link
        case .email:
            return .action
        case .static:
            return .none
        }
    }
    
    var navigationDestination: NavigationDestination {
        NavigationDestination(
            url: destination?.url,
            viewIdentifier: nil, // Don't pass identifier, use viewBuilder directly
            viewBuilder: viewBuilderForNavigationLink
        )
    }
    
    private var viewBuilderForNavigationLink: (() -> AnyView)? {
        guard type == .navigationLink,
              let viewIdentifier = destination?.viewIdentifier else {
            return nil
        }
        
        return {
            switch viewIdentifier {
            case "NotificationSettingsView":
                return AnyView(NotificationSettingsView())
            case "LocationSettingsView":
                return AnyView(LocationSettingsView())
            default:
                return AnyView(Text("Unknown View: \(viewIdentifier)"))
            }
        }
    }
}

