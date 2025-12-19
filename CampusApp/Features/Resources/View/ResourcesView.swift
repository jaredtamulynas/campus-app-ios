//
//  ResourcesView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI

struct ResourcesView: View {
    @Environment(UserSettings.self) private var userSettings

    @State private var viewModel: ResourcesViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showingFavoritesOnly = false

    init(viewModel: ResourcesViewModel = ResourcesViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    private var visibleResources: [Resource] {
        viewModel.visibleResources(for: userSettings.selectedPerspective)
    }

    private var categories: [String] {
        var seen = Set<String>()
        return visibleResources.compactMap { resource in
            guard !seen.contains(resource.category) else { return nil }
            seen.insert(resource.category)
            return resource.category
        }
    }

    var body: some View {
        NavigationStack {
            LoadStateView(state: viewModel.state, retry: { await viewModel.loadResources() }) {
                ResourcesListContent(
                    viewModel: viewModel,
                    searchText: searchText,
                    selectedCategory: $selectedCategory,
                    showingFavoritesOnly: showingFavoritesOnly,
                    categories: categories,
                    visibleResources: visibleResources
                )
            }
            .navigationTitle("Resources")
            .searchable(text: $searchText, prompt: "Search resources")
            .refreshable { await viewModel.loadResources() }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    categoryMenu
                    favoritesButton
                }
            }
            .task { await viewModel.loadResources() }
        }
    }

    // MARK: - Toolbar

    private var categoryMenu: some View {
        Menu {
            Button {
                withAnimation(.snappy) { selectedCategory = nil }
            } label: {
                Label("All", systemImage: selectedCategory == nil ? "checkmark" : "")
            }
            Divider()
            ForEach(categories, id: \.self) { category in
                Button {
                    withAnimation(.snappy) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                } label: {
                    Label(category, systemImage: selectedCategory == category ? "checkmark" : "")
                }
            }
        } label: {
            Image(systemName: selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .foregroundStyle(selectedCategory != nil ? .accent : .primary)
        }
        .accessibilityLabel("Filter by category")
        .accessibilityValue(selectedCategory ?? "All")
    }

    private var favoritesButton: some View {
        Button {
            withAnimation(.snappy) { showingFavoritesOnly.toggle() }
        } label: {
            Image(systemName: showingFavoritesOnly ? "star.fill" : "star")
                .foregroundStyle(showingFavoritesOnly ? .yellow : .primary)
        }
        .accessibilityLabel("Show favorites only")
        .accessibilityValue(showingFavoritesOnly ? "On" : "Off")
        .accessibilityAddTraits(showingFavoritesOnly ? .isSelected : [])
    }
}

// MARK: - List Content

private struct ResourcesListContent: View {
    @Environment(UserSettings.self) private var userSettings
    @Environment(\.isSearching) private var isSearching

    let viewModel: ResourcesViewModel
    let searchText: String
    @Binding var selectedCategory: String?
    let showingFavoritesOnly: Bool
    let categories: [String]
    let visibleResources: [Resource]

    private var hasSearchText: Bool { !searchText.isEmpty }

    private var filteredResources: [Resource] {
        if hasSearchText {
            return visibleResources.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        var result = visibleResources
        if showingFavoritesOnly {
            result = result.filter { viewModel.isFavorite($0.id) }
        }
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        return result
    }

    private var groupedResources: [(String, [Resource])] {
        let grouped = Dictionary(grouping: filteredResources, by: \.category)
        return categories.compactMap { category in
            guard let resources = grouped[category], !resources.isEmpty else { return nil }
            return (category, resources)
        }
    }

    private var shouldShowFilters: Bool { !isSearching }
    private var shouldShowRecent: Bool { !isSearching && selectedCategory == nil && !showingFavoritesOnly }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if shouldShowFilters {
                    filterSection
                        .id("filters")
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                if shouldShowRecent {
                    recentSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                resourceSections
            }
            .listSectionSpacing(.compact)
            .animation(.snappy, value: isSearching)
            .animation(.snappy, value: groupedResources.map(\.0))
            .onChange(of: selectedCategory) {
                withAnimation(.snappy) {
                    proxy.scrollTo("filters", anchor: .top)
                }
            }
            .onChange(of: showingFavoritesOnly) {
                withAnimation(.snappy) {
                    proxy.scrollTo("filters", anchor: .top)
                }
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    FilterChip(title: "All", isSelected: selectedCategory == nil) {
                        withAnimation(.snappy) { selectedCategory = nil }
                    }
                    .accessibilityAddTraits(selectedCategory == nil ? .isSelected : [])

                    ForEach(categories, id: \.self) { category in
                        FilterChip(title: category, isSelected: selectedCategory == category) {
                            withAnimation(.snappy) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                        .accessibilityAddTraits(selectedCategory == category ? .isSelected : [])
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Category filters")
    }

    // MARK: - Recent Section

    @ViewBuilder
    private var recentSection: some View {
        let recent = viewModel.recentlyViewedResources(for: userSettings.selectedPerspective)

        if !recent.isEmpty {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(recent) { resource in
                            CompactCard(
                                item: resource,
                                isFavorite: viewModel.isFavorite(resource.id),
                                onFavoriteToggle: { viewModel.toggleFavorite(resource.id) },
                                onTap: { viewModel.markAsViewed(resource.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, -16)
            } header: {
                ListSectionHeader("Recently Viewed") {
                    ClearAccessory {
                        withAnimation(.snappy) { viewModel.clearRecentlyViewed() }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Recently viewed resources")
        }
    }

    // MARK: - Resource Sections

    @ViewBuilder
    private var resourceSections: some View {
        if filteredResources.isEmpty {
            ContentUnavailableView(
                showingFavoritesOnly ? "No Favorites" : "No Resources",
                systemImage: showingFavoritesOnly ? "star" : "magnifyingglass",
                description: Text(showingFavoritesOnly ? "Star resources to add them here" : "Try a different search")
            )
        } else {
            ForEach(groupedResources, id: \.0) { category, resources in
                Section(category) {
                    ForEach(resources) { resource in
                        NavigatableRow(
                            item: resource,
                            isFavorite: viewModel.isFavorite(resource.id),
                            onTap: { viewModel.markAsViewed(resource.id) },
                            onFavoriteToggle: { viewModel.toggleFavorite(resource.id) }
                        )
                        .accessibilityLabel(resource.name)
                        .accessibilityHint(resource.description)
                        .transition(.opacity)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(category) section, \(resources.count) resources")
            }
        }
    }
}

#Preview {
    let settings = UserSettings()
    settings.setPerspective(.student)
    return ResourcesView(viewModel: .preview)
        .environment(settings)
}
