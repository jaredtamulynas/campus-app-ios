//
//  TVPlayerView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI
import AVKit

struct TVPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CampusManager.self) private var campusManager

    @State private var player: AVPlayer?

    /// Gets the TV stream URL from config, falls back to default
    private var streamURL: URL {
        // Look for the TV media link in config
        if let mediaLinks = campusManager.config.mediaLinks,
           let tvLink = mediaLinks.first(where: { $0.id.contains("tv") || $0.id.contains("wolfbytes") }),
           let streamURLString = tvLink.streamURL,
           let url = URL(string: streamURLString) {
            return url
        }
        // Fallback to default stream URL
        return URL(string: "http://152.14.0.22:8080/0.m3u8")!
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(.white)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            player = AVPlayer(url: streamURL)
            player?.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    TVPlayerView()
        .environment(CampusManager())
}
