//
//  LoadableContainer.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/13/25.
//

import SwiftUI

enum LoadState {
    case loading
    case loaded
    case error(Error)
}


struct LoadStateView<Content: View>: View {
    let state: LoadState
    let retry: () async -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            switch state {
            case .loading:
                DefaultLoadingView()

            case .error(let error):
                DefaultErrorView(error: error, retry: retry)

            case .loaded:
                // Content may be empty or not — view decides.
                content()
            }
        }
    }
}


struct DefaultLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("Loading…").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DefaultErrorView: View {
    let error: Error
    let retry: () async -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Unable to Load", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task { await retry() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct DefaultEmptyView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Content", systemImage: "tray")
        } description: {
            Text("Nothing to display.")
        }
    }
}
