//
//  ResourcesViewModel.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 10/30/25.
//

import Foundation

@Observable
final class ResourcesViewModel {
    private let service: ResourcesServiceProtocol
    private let favoritesKey = "favoriteResourceIds"
    private let recentlyViewedKey = "recentlyViewedResourceIds"
    private let maxRecentlyViewed = 10
    
    var resourcesData: ResourcesData?
    var state: LoadState = .loading
    var favoriteIds: Set<String> = []
    var recentlyViewedIds: [String] = []
    
    init(service: ResourcesServiceProtocol = ResourcesService()) {
        self.service = service
        loadFavorites()
        loadRecentlyViewed()
    }
    
    @MainActor
    func loadResources() async {
        state = .loading
        
        do {
            let data = try await service.fetchResources()
            self.resourcesData = data
            state = .loaded
        } catch {
            state = .error(error)
        }
    }

    func visibleResources(for perspective: PerspectiveType?) -> [Resource] {
        guard let perspective else { return [] }
        return resourcesData?.visibleResources(for: perspective) ?? []
    }
    
    // MARK: - Favorites
    
    func isFavorite(_ resourceId: String) -> Bool {
        favoriteIds.contains(resourceId)
    }
    
    func toggleFavorite(_ resourceId: String) {
        if favoriteIds.contains(resourceId) {
            favoriteIds.remove(resourceId)
        } else {
            favoriteIds.insert(resourceId)
        }
        saveFavorites()
    }
    
    func favoriteResources(for perspective: PerspectiveType?) -> [Resource] {
        let visible = visibleResources(for: perspective)
        return visible.filter { favoriteIds.contains($0.id) }
    }
    
    private func loadFavorites() {
        if let savedIds = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteIds = Set(savedIds)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: favoritesKey)
    }
    
    // MARK: - Recently Viewed
    
    func markAsViewed(_ resourceId: String) {
        // Remove if already exists (to move to front)
        recentlyViewedIds.removeAll { $0 == resourceId }
        
        // Add to front
        recentlyViewedIds.insert(resourceId, at: 0)
        
        // Trim to max size
        if recentlyViewedIds.count > maxRecentlyViewed {
            recentlyViewedIds = Array(recentlyViewedIds.prefix(maxRecentlyViewed))
        }
        
        saveRecentlyViewed()
    }
    
    func recentlyViewedResources(for perspective: PerspectiveType?) -> [Resource] {
        let visible = visibleResources(for: perspective)
        let visibleDict = Dictionary(uniqueKeysWithValues: visible.map { ($0.id, $0) })
        
        return recentlyViewedIds.compactMap { visibleDict[$0] }
    }
    
    func clearRecentlyViewed() {
        recentlyViewedIds.removeAll()
        saveRecentlyViewed()
    }
    
    private func loadRecentlyViewed() {
        if let savedIds = UserDefaults.standard.array(forKey: recentlyViewedKey) as? [String] {
            recentlyViewedIds = savedIds
        }
    }
    
    private func saveRecentlyViewed() {
        UserDefaults.standard.set(recentlyViewedIds, forKey: recentlyViewedKey)
    }
}

// MARK: - Preview Support

#if DEBUG
extension ResourcesViewModel {
    /// Creates a pre-loaded viewModel for SwiftUI Previews
    static var preview: ResourcesViewModel {
        let viewModel = ResourcesViewModel(service: PreviewResourcesService())
        viewModel.resourcesData = ResourcesData(
            resources: Resource.previewSamples,
            lastUpdated: "2025-12-04T12:00:00Z"
        )
        viewModel.state = .loaded
        return viewModel
    }
}
#endif
