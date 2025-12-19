//
//  RadioPlayerViewModel.swift
//  CampusApp
//
//  Created by Claude Code on 12/13/25.
//

import AVFoundation
import MediaPlayer

@Observable
final class RadioPlayerViewModel {
    static let shared = RadioPlayerViewModel()

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?

    var isPlaying = false
    var isLoading = false
    var currentTitle = "WolfBytes Radio"
    var currentArtist = "NC State"
    var error: Error?

    /// Default stream URL - can be overridden by config
    private static let defaultStreamURL = URL(string: "http://152.14.0.12:9000/stream/1/")!

    /// Gets the radio stream URL from config, falls back to default
    private var streamURL: URL {
        let config = CampusManager.shared.config

        // Look for the radio media link in config
        if let mediaLinks = config.mediaLinks,
           let radioLink = mediaLinks.first(where: { $0.id.contains("radio") || $0.id.contains("wknc") }),
           let streamURLString = radioLink.streamURL,
           let url = URL(string: streamURLString) {
            return url
        }

        // Fallback to default stream URL
        return Self.defaultStreamURL
    }

    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
        setupNowPlayingInfo()
    }

    deinit {
        stop()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            self.error = error
        }
    }

    // MARK: - Playback Controls

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        guard !isPlaying else { return }

        isLoading = true
        error = nil

        // Create new player item for fresh stream connection
        playerItem = AVPlayerItem(url: streamURL)

        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }

        // Observe when ready to play
        Task { @MainActor in
            do {
                // Wait for item to be ready
                try await Task.sleep(for: .milliseconds(500))
                player?.play()
                isPlaying = true
                isLoading = false
                updateNowPlayingInfo()
            } catch {
                isLoading = false
                self.error = error
            }
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        playerItem = nil
        isPlaying = false
        isLoading = false
    }

    // MARK: - Now Playing Info

    private func setupNowPlayingInfo() {
        updateNowPlayingInfo()
    }

    private func updateNowPlayingInfo() {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentTitle,
            MPMediaItemPropertyArtist: currentArtist,
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        // Add artwork if available
        if let image = UIImage(named: "belltower") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Remote Command Center

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayback()
            return .success
        }
    }

    // MARK: - Metadata Update

    func updateMetadata(title: String, artist: String) {
        currentTitle = title
        currentArtist = artist
        updateNowPlayingInfo()
    }
}
