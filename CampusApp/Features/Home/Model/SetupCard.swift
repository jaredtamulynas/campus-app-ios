//
//  SetupCard.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 11/6/25.
//

import Foundation

// MARK: - Setup Card

/// Personalization setup cards shown on Home view
/// Guides users through app configuration and preferences
struct SetupCard: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String // SF Symbol name
    let color: String // Color name
    let category: SetupCategory
    let priority: Int // Lower number = shown first
    let visibility: PerspectiveVisibility
    let steps: [SetupStep]
    
    enum SetupCategory: String, Codable {
        case personalization  // App preferences, favorites
        case transportation   // Wolfline, parking
        case campus           // Buildings, locations, dining
        case notifications    // Alert preferences
        case account          // Profile, settings
    }
    
    // MARK: - Visibility Helper
    
    func isVisible(for perspective: PerspectiveType) -> Bool {
        visibility.isVisible(for: perspective)
    }
    
    // MARK: - Hashable
    
    static func == (lhs: SetupCard, rhs: SetupCard) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Setup Step

/// Individual action within a setup card
struct SetupStep: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let order: Int
    let actionType: ActionType
    let actionData: ActionData?
    
    enum ActionType: String, Codable {
        case navigation      // Navigate to app screen
        case externalLink    // Open external URL
        case toggle          // Simple on/off setting
        case selection       // Choose from options
        case location        // Select campus location
        case resource        // Select favorite resources
    }
    
    struct ActionData: Codable, Hashable {
        // For navigation
        let screenId: String?
        
        // For links
        let url: String?
        let linkTitle: String?
        
        // For toggles/selections
        let settingKey: String?
        let options: [String]?
        
        // For locations
        let locationType: String? // "building", "dining", "parking"
        
        // For resources
        let resourceCategory: String?
    }
    
    // MARK: - Hashable
    
    static func == (lhs: SetupStep, rhs: SetupStep) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Setup Progress

/// Tracks user's setup completion progress
struct SetupProgress: Codable {
    var completedCards: Set<String> = []
    var completedSteps: Set<String> = []
    
    /// Check if setup is complete (all cards done)
    var isSetupComplete: Bool {
        // Once user completes 5+ cards, consider setup done
        // Home view will transition to dashboard mode
        completedCards.count >= 5
    }
    
    mutating func markCardComplete(_ cardId: String) {
        completedCards.insert(cardId)
    }
    
    mutating func markStepComplete(_ stepId: String) {
        completedSteps.insert(stepId)
    }
    
    func isCardComplete(_ cardId: String) -> Bool {
        completedCards.contains(cardId)
    }
    
    func isStepComplete(_ stepId: String) -> Bool {
        completedSteps.contains(stepId)
    }
    
    /// Get completion percentage (0.0 to 1.0)
    func completionPercentage(totalCards: Int) -> Double {
        guard totalCards > 0 else { return 0.0 }
        return Double(completedCards.count) / Double(totalCards)
    }
}

// MARK: - Setup Cards Data Container

/// Container for all setup cards loaded from JSON
struct SetupCardsData: Codable {
    let cards: [SetupCard]
    let lastUpdated: String?
    
    /// Get all cards visible for the given perspective, sorted by priority
    func visibleCards(for perspective: PerspectiveType) -> [SetupCard] {
        return cards
            .filter { $0.isVisible(for: perspective) }
            .sorted { $0.priority < $1.priority }
    }
}

