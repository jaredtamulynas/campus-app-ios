//
//  CustomViewResolver.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/14/25.
//

import SwiftUI

struct CustomViewResolver: View {
    let viewIdentifier: String
    let resource: Resource
    
    var body: some View {
        Group {
            if let contactInfo = resource.contactInfo {
                ResourceContactSheet(resource: resource, contactInfo: contactInfo)
            } else {
                // Resolve custom view based on identifier
                switch viewIdentifier {
                case "WolflineMapView":
                    Text("Wolfline Map View")
                        .navigationTitle("Wolfline Map")
                case "DiningLocationsView":
                    Text("Dining Locations View")
                        .navigationTitle("Dining Locations")
                default:
                    Text("Unknown View: \(viewIdentifier)")
                        .navigationTitle(resource.name)
                }
            }
        }
    }
}
