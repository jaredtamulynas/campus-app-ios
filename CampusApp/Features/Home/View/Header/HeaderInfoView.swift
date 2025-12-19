//
//  HeaderInfoView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct HeaderInfoView: View {
    @Environment(CampusManager.self) private var campusManager
    @Environment(WeatherViewModel.self) private var weatherViewModel

    @State private var showLiveCampusView = false
    @State private var showWeatherSheet = false

    let style: Style

    enum Style {
        case hero    // White text with shadows for overlay on image
        case compact // System colors for material background
    }

    private var weatherURL: URL? {
        guard let urlString = campusManager.config.weatherURL else { return nil }
        return URL(string: urlString)
    }

    var body: some View {
        HStack {
            dateLabel
            Spacer()
            weatherButton
            liveButton
        }
        .font(.subheadline)
        .modifier(StyleModifier(style: style))
        .sheet(isPresented: $showLiveCampusView) {
            LiveCampusSheet(weather: weatherViewModel.weather)
        }
        .sheet(isPresented: $showWeatherSheet) {
            if let url = weatherURL {
                WebViewSheet(url: url, title: "Weather")
            }
        }
    }

    private var dateLabel: some View {
        Label {
            Text(Date().formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
        } icon: {
            Image(systemName: "calendar")
        }
    }

    @ViewBuilder
    private var weatherButton: some View {
        let label = Label(weatherViewModel.temperatureDisplay, systemImage: weatherViewModel.weatherIcon)

        if weatherURL != nil {
            Button { showWeatherSheet = true } label: { label }
                .buttonStyle(.plain)
        } else {
            label
        }
    }

    private var liveButton: some View {
        Button { showLiveCampusView = true } label: {
            Label("Live", systemImage: "camera.fill")
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Style Modifier

private struct StyleModifier: ViewModifier {
    let style: HeaderInfoView.Style

    func body(content: Content) -> some View {
        switch style {
        case .hero:
            content
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        case .compact:
            content
                .foregroundStyle(.primary)
        }
    }
}

#Preview("Hero") {
    ZStack {
        Color.black
        HeaderInfoView(style: .hero)
            .padding()
    }
    .environment(CampusManager())
    .environment(WeatherViewModel())
}

#Preview("Compact") {
    HeaderInfoView(style: .compact)
        .padding()
        .background(.ultraThinMaterial)
        .environment(CampusManager())
        .environment(WeatherViewModel())
}
