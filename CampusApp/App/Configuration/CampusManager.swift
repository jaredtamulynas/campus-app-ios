//
//  CampusManager.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import Foundation

@Observable
final class CampusManager {
    static let shared = CampusManager()
    var config: CampusConfig

    init() {
        let filename = "configurator.json"
        config = CampusConfig.load(from: filename)
    }
}
