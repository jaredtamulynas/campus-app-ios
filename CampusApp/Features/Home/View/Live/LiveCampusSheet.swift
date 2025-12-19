//
//  LiveCampusSheet.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct LiveCampusSheet: View {
    let weather: WeatherItem?
    @Environment(\.dismiss) private var dismiss
    @Environment(CampusManager.self) private var campusManager

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ScrollView {
                    VStack(spacing: 0) {
                        cameraImageView

                        VStack(spacing: 16) {
                            HStack {
                                LiveBadge()
                                Text("Campus Camera")
                                    .font(.headline)
                                Spacer()
                            }

                            Text("Live view from the campus camera. Image updates every 20 minutes.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let weather = weather {
                                weatherCard(weather: weather)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Live Campus View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var cameraImageView: some View {
        if let imageUrl = weather?.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)

                case .failure:
                    imagePlaceholder

                case .empty:
                    ProgressView()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))

                @unknown default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "video.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Camera unavailable")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray5))
    }

    private func weatherCard(weather: WeatherItem) -> some View {
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Image(systemName: weather.sfSymbol)
                    .font(.title2)
                Text(weather.temperatureString)
                    .font(.headline)
            }

            Divider()
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Label(weather.sunriseFormatted, systemImage: "sunrise.fill")
                Label(weather.sunsetFormatted, systemImage: "sunset.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LiveCampusSheet(weather: nil)
        .environment(CampusManager())
}
