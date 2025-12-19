//
//  WeatherViewModel.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/5/25.
//

import Foundation
import FirebaseDatabase
import SwiftUI

@Observable
final class WeatherViewModel {
    
    // MARK: - Properties
    
    private static let firebasePath = "weather"
    private var observerHandle: DatabaseHandle?
    
    var weather: WeatherItem?
    var error: Error?
    var isLoading = false
    
    // MARK: - Computed Properties
    
    /// Current temperature string or placeholder
    var temperatureDisplay: String {
        weather?.temperatureString ?? "--°F"
    }
    
    /// Current weather icon (SF Symbol name)
    var weatherIcon: String {
        weather?.sfSymbol ?? defaultWeatherIcon
    }
    
    /// Fallback weather icon based on time of day
    private var defaultWeatherIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return (hour >= 6 && hour < 20) ? "sun.max.fill" : "moon.stars.fill"
    }
    
    /// Whether weather data is available
    var hasWeather: Bool {
        weather != nil
    }
    
    // MARK: - Public Methods
    
    /// Start observing weather updates from Firebase (runs for app lifetime)
    func startObserving() {
        guard observerHandle == nil else { return }
        
        isLoading = true
        error = nil
        
        observerHandle = FirebaseService.observeRaw(path: Self.firebasePath) { [weak self] data in
            guard let self = self else { return }
            
            // Parse weather data
            guard let sfSymbol = data["sfSymbol"] as? String,
                  let temperature = data["temperature"] as? Int,
                  let sunrise = data["sunrise"] as? TimeInterval,
                  let sunset = data["sunset"] as? TimeInterval else {
                self.error = FirebaseError.decodingFailed(
                    path: Self.firebasePath,
                    underlying: NSError(domain: "WeatherViewModel", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing required weather fields"
                    ])
                )
                self.isLoading = false
                return
            }
            
            // Optional fields
            let imageUrl = data["imageUrl"] as? String
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.weather = WeatherItem(
                    temperature: temperature,
                    sfSymbol: sfSymbol,
                    sunrise: sunrise,
                    sunset: sunset,
                    imageUrl: imageUrl
                )
                self.isLoading = false
                self.error = nil
            }
        } onError: { [weak self] error in
            self?.error = error
            self?.isLoading = false
            print("Weather error: \(error.localizedDescription)")
        }
    }
}

