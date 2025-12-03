//
//  CampusConfig.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import Foundation
import CoreLocation
import MapKit

struct CampusConfig: Codable {
    let id: String
    let displayName: String
    let bundleDisplayName: String
    let secondaryColor: String
    let logoURL: String
    let welcomeMessage: String
    let description: String
    let mapCenter: MapCenter
    let mapZoom: MapZoom
    
    struct MapCenter: Codable {
        let latitude: Double
        let longitude: Double
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    struct MapZoom: Codable {
        let latitudeDelta: Double
        let longitudeDelta: Double
        
        var span: MKCoordinateSpan {
            MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }
    }
    
    var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: mapCenter.coordinate, span: mapZoom.span)
    }

    static func load(from filename: String) -> CampusConfig {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Missing config file \(filename)")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(CampusConfig.self, from: data)
            return config
        } catch {
            fatalError("Failed to decode \(filename): \(error)")
        }
    }
}
