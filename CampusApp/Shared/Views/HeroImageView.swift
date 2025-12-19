//
//  HeroImageView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/8/25.
//

import SwiftUI

struct HeroImageView: View {
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Environment(CampusManager.self) private var campusManager

    let imageUrl: String?

    @State private var loadState: LoadState = .loading

    private enum LoadState {
        case loading, loaded(Image), failed
    }

    // Cache refreshes every 20 minutes
    private var cacheVersion: Int {
        Int(Date().timeIntervalSince1970 / (20 * 60))
    }

    private var isNighttime: Bool {
        if let weather = weatherViewModel.weather {
            return !weather.isDaytime
        }
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 20 || hour < 6
    }

    private var headerImageUrl: URL? {
        let suffix = isNighttime ? "-dark" : ""
        return URL(string: "\(campusManager.config.headerImageBaseURL)/header\(suffix).png?v=\(cacheVersion)")
    }

    var body: some View {
        ZStack {
            imageContent
            gradientOverlay
        }
        .clipped()
    }

    @ViewBuilder
    private var imageContent: some View {
        if let urlString = imageUrl, let url = URL(string: urlString) {
            remoteImage(url: url)
        } else if let url = headerImageUrl {
            remoteImage(url: url)
        } else {
            fallbackImage
        }
    }

    private func remoteImage(url: URL) -> some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.25))) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                fallbackImage
            case .empty:
                shimmer
            @unknown default:
                shimmer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fallbackImage: some View {
        Image("belltower")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var shimmer: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay { ShimmerEffect() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.black.opacity(0), .black.opacity(0.1), .black.opacity(0.45)],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}

// MARK: - Shimmer Effect

private struct ShimmerEffect: View {
    @State private var offset: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [Color(.systemGray5), Color(.systemGray4), Color(.systemGray5)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 2)
            .offset(x: offset * geo.size.width)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    offset = 1
                }
            }
        }
        .clipped()
    }
}

#Preview {
    HeroImageView(imageUrl: nil)
        .frame(height: 300)
        .environment(CampusManager())
        .environment(WeatherViewModel())
}
