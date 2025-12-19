//
//  WeatherItem.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/5/25.
//

import Foundation

// MARK: - Weather Item

struct WeatherItem: Codable, Equatable {
    let temperature: Int
    let sfSymbol: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let imageUrl: String?
    
    // MARK: - Computed Properties
    
    /// Formatted temperature string (e.g., "72°F")
    var temperatureString: String {
        "\(temperature)°F"
    }
    
    /// Sunrise time as Date
    var sunriseDate: Date {
        Date(timeIntervalSince1970: sunrise)
    }
    
    /// Sunset time as Date
    var sunsetDate: Date {
        Date(timeIntervalSince1970: sunset)
    }
    
    /// Fraction of day when sunrise occurs (0.0 - 1.0)
    var todaysSunrise: Double {
        fractionOfDay(for: sunrise)
    }
    
    /// Fraction of day when sunset occurs (0.0 - 1.0)
    var todaysSunset: Double {
        fractionOfDay(for: sunset)
    }
    
    /// Whether it's currently daytime based on sunrise/sunset
    var isDaytime: Bool {
        let now = Date().timeIntervalSince1970
        return now >= sunrise && now < sunset
    }
    
    /// Formatted sunrise time (e.g., "6:42 AM")
    var sunriseFormatted: String {
        formatTime(sunriseDate)
    }
    
    /// Formatted sunset time (e.g., "7:28 PM")
    var sunsetFormatted: String {
        formatTime(sunsetDate)
    }
    
    // MARK: - Private Helpers
    
    private func fractionOfDay(for timeInterval: TimeInterval) -> Double {
        let date = Date(timeIntervalSince1970: timeInterval)
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)
        return (hour + (minute / 60)) / 24
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview Helper

extension WeatherItem {
    static let preview = WeatherItem(
        temperature: 72,
        sfSymbol: "sun.max.fill",
        sunrise: Date().timeIntervalSince1970 - 21600, // 6 hours ago
        sunset: Date().timeIntervalSince1970 + 21600,  // 6 hours from now
        imageUrl: nil
    )
}

