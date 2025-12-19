//
//  GuidesView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/12/25.
//

import SwiftUI

struct GuidesView: View {
    @Environment(UserSettings.self) private var userSettings
    @State private var viewModel = GuidesViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            LoadStateView(state: viewModel.state) {
                await viewModel.loadGuides()
            } content: {
                guidesContent
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Guides")
            .navigationDestination(for: Guide.self) { guide in
                GuideDetailView(guide: guide)
            }
            .searchable(text: $searchText, prompt: "Search guides")
            .task {
                await viewModel.loadGuides()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var allGuides: [Guide] {
        viewModel.visibleGuides(for: userSettings.selectedPerspective)
    }
    
    /// Guides user has started but not completed all todos
    private var activeGuides: [Guide] {
        allGuides.filter { guide in
            let isStarted = userSettings.isGuideStarted(guide.id)
            let totalTodos = guide.todos?.count ?? 0
            let completedTodos = userSettings.completedTodoCount(for: guide.id, totalTodos: totalTodos)
            let allTodosComplete = totalTodos > 0 && completedTodos >= totalTodos
            
            // Active if started and has incomplete todos
            return isStarted && totalTodos > 0 && !allTodosComplete
        }
    }
    
    /// Featured guides (excluding active ones)
    private var featuredGuides: [Guide] {
        let activeIds = Set(activeGuides.map { $0.id })
        return allGuides.filter { $0.isFeatured && !activeIds.contains($0.id) }
    }
    
    /// Remaining guides (not active, not featured)
    private var remainingGuides: [Guide] {
        let activeIds = Set(activeGuides.map { $0.id })
        let featuredIds = Set(featuredGuides.map { $0.id })
        return allGuides.filter { !activeIds.contains($0.id) && !featuredIds.contains($0.id) }
    }
    
    private var searchResults: [Guide] {
        guard !searchText.isEmpty else { return [] }
        return allGuides.filter { guide in
            guide.title.localizedCaseInsensitiveContains(searchText) ||
            guide.description.localizedCaseInsensitiveContains(searchText) ||
            guide.department.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var isSearching: Bool {
        !searchText.isEmpty
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var guidesContent: some View {
        if allGuides.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    if isSearching {
                        searchResultsSection
                    } else {
                        activeGuidesSection
                        featuredGuidesSection
                        allGuidesSection
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.loadGuides()
            }
        }
    }
    
    // MARK: - Active Guides Section
    
    @ViewBuilder
    private var activeGuidesSection: some View {
        if !activeGuides.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Continue")
                        .font(.headline)
                    
                    Text("\(activeGuides.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.accent, in: Capsule())
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                HorizontalGuidesScroll(guides: activeGuides)
            }
        }
    }
    
    // MARK: - Featured Guides Section
    
    @ViewBuilder
    private var featuredGuidesSection: some View {
        if !featuredGuides.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Featured")
                    .font(.headline)
                    .padding(.horizontal)
                
                HorizontalGuidesScroll(guides: featuredGuides)
            }
        }
    }
    
    // MARK: - All Guides Section
    
    @ViewBuilder
    private var allGuidesSection: some View {
        let guidesToShow = remainingGuides.isEmpty && activeGuides.isEmpty && featuredGuides.isEmpty 
            ? allGuides 
            : remainingGuides
        
        if !guidesToShow.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("All Guides")
                    .font(.headline)
                    .padding(.horizontal)
                
                GuidesGridView(guides: guidesToShow)
            }
        }
    }
    
    // MARK: - Search Results Section
    
    @ViewBuilder
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            if searchResults.isEmpty {
                noResultsView
            } else {
                GuidesGridView(guides: searchResults)
            }
        }
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Guides Found")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Guides Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Guides will appear here based on your selected perspective")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    let settings = UserSettings()
    settings.setPerspective(.student)
    
    // Simulate a guide in progress
    settings.markGuideStarted("wolfpack-welcome-week")
    settings.toggleTodoComplete("wolfpack-welcome-week", todoId: "todo-1")
    settings.toggleTodoComplete("wolfpack-welcome-week", todoId: "todo-2")
    
    return GuidesView()
        .environment(settings)
}
