//
//  ColorParser.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/16/25.
//

import SwiftUI

enum ColorParser {
    /// Parses a color string to a SwiftUI Color
    /// Returns `.accentColor` if the string is nil or doesn't match a known color
    static func parse(_ colorString: String?) -> Color {
        guard let colorString = colorString else { return .accentColor }
        
        switch colorString.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "gray": return .gray
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        case "brown": return .brown
        case "cyan": return .cyan
        case "mint": return .mint
        default: return .accentColor
        }
    }
}

