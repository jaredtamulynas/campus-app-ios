//
//  UserSettings.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/27/25.
//

import Foundation

@Observable
final class UserSettings {
    private let perspectiveKey = "selectedPerspective"
    private let setupProgressKey = "setupProgress"
    private let dashboardStateKey = "dashboardState"
    
    var selectedPerspective: PerspectiveType?
    var setupProgress: SetupProgress
    var dashboardState: DashboardState
    
    init() {
        // Load saved perspective
        if let savedRawValue = UserDefaults.standard.string(forKey: perspectiveKey),
           let perspective = PerspectiveType(rawValue: savedRawValue) {
            self.selectedPerspective = perspective
        } else {
            self.selectedPerspective = nil
        }
        
        // Load setup progress
        if let data = UserDefaults.standard.data(forKey: setupProgressKey),
           let progress = try? JSONDecoder().decode(SetupProgress.self, from: data) {
            self.setupProgress = progress
        } else {
            self.setupProgress = SetupProgress()
        }
        
        // Load dashboard state
        if let data = UserDefaults.standard.data(forKey: dashboardStateKey),
           let state = try? JSONDecoder().decode(DashboardState.self, from: data) {
            self.dashboardState = state
        } else {
            self.dashboardState = DashboardState()
        }
    }
    
    func setPerspective(_ perspective: PerspectiveType) {
        selectedPerspective = perspective
        UserDefaults.standard.set(perspective.rawValue, forKey: perspectiveKey)
    }
    
    func markCardComplete(_ cardId: String) {
        setupProgress.markCardComplete(cardId)
        saveSetupProgress()
    }
    
    func markStepComplete(_ stepId: String) {
        setupProgress.markStepComplete(stepId)
        saveSetupProgress()
    }
    
    private func saveSetupProgress() {
        if let data = try? JSONEncoder().encode(setupProgress) {
            UserDefaults.standard.set(data, forKey: setupProgressKey)
        }
    }
    
    // MARK: - Dashboard State Management
    
    func saveDashboardState() {
        if let data = try? JSONEncoder().encode(dashboardState) {
            UserDefaults.standard.set(data, forKey: dashboardStateKey)
        }
    }
    
    func activateTrack(_ trackId: String, quickInfo: TrackQuickInfo) {
        dashboardState.activateTrack(trackId, quickInfo: quickInfo)
        saveDashboardState()
    }
    
    func deactivateTrack(_ trackId: String) {
        dashboardState.deactivateTrack(trackId)
        saveDashboardState()
    }
    
    func updateTrackInfo(_ trackId: String, quickInfo: TrackQuickInfo) {
        dashboardState.updateTrackInfo(trackId, quickInfo: quickInfo)
        saveDashboardState()
    }
    
    func selectGuide(_ guideId: String) {
        dashboardState.selectGuide(guideId)
        saveDashboardState()
    }
    
    func clearGuide() {
        dashboardState.clearGuide()
        saveDashboardState()
    }
    
    // MARK: - Guide Progress
    
    func markGuideStepComplete(_ guideId: String, stepId: String, totalSteps: Int) {
        dashboardState.markGuideStepComplete(guideId, stepId: stepId, totalSteps: totalSteps)
        saveDashboardState()
    }
    
    func markGuideStepIncomplete(_ guideId: String, stepId: String) {
        dashboardState.markGuideStepIncomplete(guideId, stepId: stepId)
        saveDashboardState()
    }
    
    func updateGuideAccess(_ guideId: String, totalSteps: Int) {
        dashboardState.updateGuideAccess(guideId, totalSteps: totalSteps)
        saveDashboardState()
    }
    
    func getGuideProgress(_ guideId: String) -> GuideProgress? {
        dashboardState.getGuideProgress(guideId)
    }
    
    func isGuideStepComplete(_ guideId: String, stepId: String) -> Bool {
        dashboardState.isGuideStepComplete(guideId, stepId: stepId)
    }
    
    // MARK: - Started Guides
    
    func markGuideStarted(_ guideId: String) {
        dashboardState.markGuideStarted(guideId)
        saveDashboardState()
    }
    
    func isGuideStarted(_ guideId: String) -> Bool {
        dashboardState.isGuideStarted(guideId)
    }
    
    // MARK: - Todo Management
    
    func toggleTodoComplete(_ guideId: String, todoId: String) {
        dashboardState.toggleTodoComplete(guideId, todoId: todoId)
        saveDashboardState()
    }
    
    func isTodoComplete(_ guideId: String, todoId: String) -> Bool {
        dashboardState.isTodoComplete(guideId, todoId: todoId)
    }
    
    func completedTodoCount(for guideId: String, totalTodos: Int) -> Int {
        dashboardState.completedTodoCount(for: guideId, totalTodos: totalTodos)
    }
    
    // MARK: - Event RSVP Management
    
    func toggleEventRSVP(_ guideId: String, eventId: String) {
        dashboardState.toggleEventRSVP(guideId, eventId: eventId)
        saveDashboardState()
    }
    
    func isEventRSVPd(_ guideId: String, eventId: String) -> Bool {
        dashboardState.isEventRSVPd(guideId, eventId: eventId)
    }
    
    func rsvpEventCount(for guideId: String) -> Int {
        dashboardState.rsvpEventCount(for: guideId)
    }
    
    // MARK: - Calendar Event Management
    
    func markEventAddedToCalendar(_ guideId: String, eventId: String) {
        dashboardState.markEventAddedToCalendar(guideId, eventId: eventId)
        saveDashboardState()
    }
    
    func isEventAddedToCalendar(_ guideId: String, eventId: String) -> Bool {
        dashboardState.isEventAddedToCalendar(guideId, eventId: eventId)
    }
    
    func toggleFavoriteResource(_ resourceId: String) {
        dashboardState.toggleFavoriteResource(resourceId)
        saveDashboardState()
    }
    
    func addRecentResource(_ resourceId: String) {
        dashboardState.addRecentResource(resourceId)
        saveDashboardState()
    }
    
    func clear() {
        selectedPerspective = nil
        UserDefaults.standard.removeObject(forKey: perspectiveKey)
        
        setupProgress = SetupProgress()
        UserDefaults.standard.removeObject(forKey: setupProgressKey)
        
        dashboardState = DashboardState()
        UserDefaults.standard.removeObject(forKey: dashboardStateKey)
    }
    
    var hasSelection: Bool { selectedPerspective != nil }
}
