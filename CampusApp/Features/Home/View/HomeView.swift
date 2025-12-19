//
//  HomeView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(UserSettings.self) private var userSettings
    @Environment(CampusManager.self) private var campusManager
    @Environment(WeatherViewModel.self) private var weatherViewModel

    @State private var viewModel = HomeViewModel()
    @State private var resourcesViewModel = ResourcesViewModel()
    @State private var radioPlayer = RadioPlayerViewModel.shared

    @State private var showCompactHeader = false
    @State private var showTVPlayer = false
    @State private var selectedWidgetType: LiveWidgetType?
    @State private var selectedEvent: CampusEvent?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    // Hero Header - scrolls with content
                    HeroHeaderView()
                        .onScrollVisibilityChange(threshold: 0.3) { visible in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCompactHeader = !visible
                            }
                        }

                    // Dashboard Content
                    LiveCampusSectionView(
                        widgets: liveWidgets,
                        onWidgetTap: { type in selectedWidgetType = type }
                    )
                    
                    EventsSectionView(
                        events: viewModel.upcomingEvents,
                        onEventTap: { event in selectedEvent = event }
                    )

                    MediaSectionView(
                        radioPlayer: radioPlayer,
                        onTVTap: { showTVPlayer = true }
                    )

                    if !featuredResources.isEmpty {
                        FeaturedSectionView(
                            resources: featuredResources,
                            isFavorite: { resourcesViewModel.isFavorite($0) },
                            onFavoriteToggle: { resourcesViewModel.toggleFavorite($0) },
                            onTap: { resourcesViewModel.markAsViewed($0) }
                        )
                    }

                    if !favoriteResources.isEmpty {
                        FavoritesSectionView(
                            resources: favoriteResources,
                            onFavoriteToggle: { resourcesViewModel.toggleFavorite($0) },
                            onTap: { resourcesViewModel.markAsViewed($0) }
                        )
                    }
                }
                .padding(.bottom, 24)
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                if showCompactHeader {
                    CompactHeaderView()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .task {
                await viewModel.loadData()
                await resourcesViewModel.loadResources()
            }
            .refreshable {
                await viewModel.loadData()
            }
            .navigationDestination(item: $selectedWidgetType) { type in
                liveWidgetDetailView(for: type)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailSheet(event: event)
            }
            .fullScreenCover(isPresented: $showTVPlayer) {
                TVPlayerView()
            }
        }
    }
    

    // MARK: - Live Widgets

    private var liveWidgets: [LiveWidgetDisplay] {
        [
            viewModel.wolflineWidget,
            viewModel.parkingWidget,
            viewModel.diningWidget,
            viewModel.recreationWidget
        ]
    }

    // MARK: - Live Widget Detail View Router

    @ViewBuilder
    private func liveWidgetDetailView(for type: LiveWidgetType) -> some View {
        switch type {
        case .parking:
            ParkingDetailView(data: viewModel.parkingData)
        case .wolfline:
            WolflineDetailView(data: viewModel.wolflineData)
        case .dining:
            DiningDetailView(data: viewModel.diningData)
        case .recreation:
            RecreationDetailView(data: viewModel.recreationData)
        }
    }

    // MARK: - Resources

    private var featuredResources: [Resource] {
        resourcesViewModel.visibleResources(for: userSettings.selectedPerspective)
            .filter { $0.isFeatured }
    }

    private var favoriteResources: [Resource] {
        resourcesViewModel.visibleResources(for: userSettings.selectedPerspective)
            .filter { resourcesViewModel.isFavorite($0.id) }
    }
}

// MARK: - LiveWidgetType Identifiable

extension LiveWidgetType: Identifiable {
    var id: String { rawValue }
}

#Preview {
    HomeView()
        .environment(CampusManager())
        .environment(UserSettings())
        .environment(WeatherViewModel())
}
