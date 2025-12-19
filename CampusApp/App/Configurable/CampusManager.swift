//
//  CampusManager.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import Foundation

@Observable
final class CampusManager {
    /// Shared instance for services that need static config access
    static let shared = CampusManager()

    let config: CampusConfig

    init() {
        // Read CAMPUS_ID from Info.plist (it’s auto-populated from Build Settings)
        guard let campusID = Bundle.main.object(forInfoDictionaryKey: "CAMPUS_ID") as? String else {
            fatalError("CAMPUS_ID not set in build settings")
        }

        let filename = "\(campusID).json"
        config = CampusConfig.load(from: filename)
    }
}
