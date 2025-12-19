//
//  DashboardModels.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/12/25.
//

import Foundation

// MARK: - Dashboard Track

/// Trackable items that appear as cards on the dashboard
/// When selected, shows quick info and acts as a widget
struct DashboardTrack: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String // SF Symbol name
    let color: String // Color name
    let type: TrackType
    let visibility: PerspectiveVisibility
    
    enum TrackType: String, Codable {
        case routes        // Track bus routes
        case parking       // Track parking spots
        case dining        // Track dining locations
        case classes       // Track class schedule
        case events        // Track campus events
        case packages      // Track package deliveries
    }
    
    // MARK: - Visibility Helper
    
    func isVisible(for perspective: PerspectiveType) -> Bool {
        visibility.isVisible(for: perspective)
    }
    
    // MARK: - Hashable
    
    static func == (lhs: DashboardTrack, rhs: DashboardTrack) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Track Quick Info

/// Quick information displayed when a track is active on dashboard
struct TrackQuickInfo: Codable, Hashable {
    let primaryText: String     // Main info (e.g., "Blue, Red routes")
    let secondaryText: String?  // Additional info (e.g., "Next: 5 mins")
    let status: TrackStatus?    // Current status indicator
    let lastUpdated: Date?      // When info was last refreshed
    
    enum TrackStatus: String, Codable {
        case active     // Green indicator
        case warning    // Yellow indicator
        case inactive   // Gray indicator
        case error      // Red indicator
    }
}

// MARK: - Dashboard State

/// Persisted state for the user's dashboard configuration
/// Stores selected tracks, guides, and favorites for quick access
struct DashboardState: Codable {
    var activeTracks: Set<String> = []      // IDs of tracks user has activated
    var selectedGuideId: String?            // Currently selected guide for quick access
    var favoriteResourceIds: Set<String> = [] // Favorite resources for quick access
    var recentResourceIds: [String] = []    // Recently viewed resources (ordered)
    var trackQuickInfo: [String: TrackQuickInfo] = [:] // Track ID -> Quick info
    var guideProgress: [String: GuideProgress] = [:] // Guide ID -> Progress
    var startedGuideIds: Set<String> = []   // Guides user has started (for analytics)
    var completedTodoIds: Set<String> = []  // "guideId:todoId" format
    var rsvpEventIds: Set<String> = []      // "guideId:eventId" format for RSVP'd events
    var addedToCalendarEventIds: Set<String> = [] // Events already added to calendar
    
    // MARK: - Track Management
    
    mutating func activateTrack(_ trackId: String, quickInfo: TrackQuickInfo) {
        activeTracks.insert(trackId)
        trackQuickInfo[trackId] = quickInfo
    }
    
    mutating func deactivateTrack(_ trackId: String) {
        activeTracks.remove(trackId)
        trackQuickInfo.removeValue(forKey: trackId)
    }
    
    func isTrackActive(_ trackId: String) -> Bool {
        activeTracks.contains(trackId)
    }
    
    mutating func updateTrackInfo(_ trackId: String, quickInfo: TrackQuickInfo) {
        trackQuickInfo[trackId] = quickInfo
    }
    
    // MARK: - Guide Management
    
    mutating func selectGuide(_ guideId: String) {
        selectedGuideId = guideId
    }
    
    mutating func clearGuide() {
        selectedGuideId = nil
    }
    
    var hasSelectedGuide: Bool {
        selectedGuideId != nil
    }
    
    // MARK: - Guide Progress Management
    
    mutating func markGuideStepComplete(_ guideId: String, stepId: String, totalSteps: Int) {
        var progress = guideProgress[guideId] ?? GuideProgress(completedStepIds: [], totalSteps: totalSteps)
        progress.completedStepIds.insert(stepId)
        progress.totalSteps = totalSteps
        progress.lastAccessedDate = Date()
        guideProgress[guideId] = progress
    }
    
    mutating func markGuideStepIncomplete(_ guideId: String, stepId: String) {
        guideProgress[guideId]?.completedStepIds.remove(stepId)
    }
    
    mutating func updateGuideAccess(_ guideId: String, totalSteps: Int) {
        var progress = guideProgress[guideId] ?? GuideProgress(completedStepIds: [], totalSteps: totalSteps)
        progress.lastAccessedDate = Date()
        progress.totalSteps = totalSteps
        guideProgress[guideId] = progress
    }
    
    func getGuideProgress(_ guideId: String) -> GuideProgress? {
        guideProgress[guideId]
    }
    
    func isGuideStepComplete(_ guideId: String, stepId: String) -> Bool {
        guideProgress[guideId]?.completedStepIds.contains(stepId) ?? false
    }
    
    // MARK: - Favorites Management
    
    mutating func toggleFavoriteResource(_ resourceId: String) {
        if favoriteResourceIds.contains(resourceId) {
            favoriteResourceIds.remove(resourceId)
        } else {
            favoriteResourceIds.insert(resourceId)
        }
    }
    
    func isResourceFavorited(_ resourceId: String) -> Bool {
        favoriteResourceIds.contains(resourceId)
    }
    
    // MARK: - Recent Resources Management
    
    mutating func addRecentResource(_ resourceId: String) {
        // Remove if already exists to move to front
        recentResourceIds.removeAll { $0 == resourceId }
        // Add to front
        recentResourceIds.insert(resourceId, at: 0)
        // Keep only last 10
        if recentResourceIds.count > 10 {
            recentResourceIds = Array(recentResourceIds.prefix(10))
        }
    }
    
    // MARK: - Started Guides Management
    
    mutating func markGuideStarted(_ guideId: String) {
        startedGuideIds.insert(guideId)
    }
    
    func isGuideStarted(_ guideId: String) -> Bool {
        startedGuideIds.contains(guideId)
    }
    
    // MARK: - Todo Management
    
    private func todoKey(_ guideId: String, _ todoId: String) -> String {
        "\(guideId):\(todoId)"
    }
    
    mutating func toggleTodoComplete(_ guideId: String, todoId: String) {
        let key = todoKey(guideId, todoId)
        if completedTodoIds.contains(key) {
            completedTodoIds.remove(key)
        } else {
            completedTodoIds.insert(key)
        }
    }
    
    mutating func markTodoComplete(_ guideId: String, todoId: String) {
        completedTodoIds.insert(todoKey(guideId, todoId))
    }
    
    mutating func markTodoIncomplete(_ guideId: String, todoId: String) {
        completedTodoIds.remove(todoKey(guideId, todoId))
    }
    
    func isTodoComplete(_ guideId: String, todoId: String) -> Bool {
        completedTodoIds.contains(todoKey(guideId, todoId))
    }
    
    func completedTodoCount(for guideId: String, totalTodos: Int) -> Int {
        completedTodoIds.filter { $0.hasPrefix("\(guideId):") }.count
    }
    
    // MARK: - Event RSVP Management
    
    private func eventKey(_ guideId: String, _ eventId: String) -> String {
        "\(guideId):\(eventId)"
    }
    
    mutating func toggleEventRSVP(_ guideId: String, eventId: String) {
        let key = eventKey(guideId, eventId)
        if rsvpEventIds.contains(key) {
            rsvpEventIds.remove(key)
        } else {
            rsvpEventIds.insert(key)
        }
    }
    
    func isEventRSVPd(_ guideId: String, eventId: String) -> Bool {
        rsvpEventIds.contains(eventKey(guideId, eventId))
    }
    
    func rsvpEventCount(for guideId: String) -> Int {
        rsvpEventIds.filter { $0.hasPrefix("\(guideId):") }.count
    }
    
    // MARK: - Calendar Event Management
    
    mutating func markEventAddedToCalendar(_ guideId: String, eventId: String) {
        addedToCalendarEventIds.insert(eventKey(guideId, eventId))
    }
    
    func isEventAddedToCalendar(_ guideId: String, eventId: String) -> Bool {
        addedToCalendarEventIds.contains(eventKey(guideId, eventId))
    }
}

// MARK: - Dashboard Tracks Data Container

/// Container for all available tracks loaded from JSON
struct DashboardTracksData: Codable {
    let tracks: [DashboardTrack]
    let lastUpdated: String?
    
    /// Get all tracks visible for the given perspective
    func visibleTracks(for perspective: PerspectiveType) -> [DashboardTrack] {
        return tracks.filter { $0.isVisible(for: perspective) }
    }
    
    /// Get tracks by type
    func tracks(ofType type: DashboardTrack.TrackType, for perspective: PerspectiveType) -> [DashboardTrack] {
        return visibleTracks(for: perspective).filter { $0.type == type }
    }
}

// MARK: - Guide Progress

/// Tracks user progress through a guide's steps
struct GuideProgress: Codable, Hashable {
    var completedStepIds: Set<String> = []
    var totalSteps: Int
    var lastAccessedDate: Date?
    
    var completedCount: Int {
        completedStepIds.count
    }
    
    var progressPercentage: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedCount) / Double(totalSteps)
    }
    
    var isComplete: Bool {
        totalSteps > 0 && completedCount >= totalSteps
    }
    
    var isStarted: Bool {
        completedCount > 0
    }
}

