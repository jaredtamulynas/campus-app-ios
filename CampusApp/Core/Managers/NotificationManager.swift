//
//  NotificationManager.swift
//  CampusApp
//
//  Created by Claude Code on 12/18/25.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Topic Subscriptions

    enum Topic: String, CaseIterable {
        case wolfAlerts = "wolf-alerts"
        case campusEvents = "campus-events"
        case athletics = "athletics"
        case news = "news"

        var displayName: String {
            switch self {
            case .wolfAlerts: return "WolfAlerts"
            case .campusEvents: return "Campus Events"
            case .athletics: return "Athletics"
            case .news: return "News & Updates"
            }
        }

        var description: String {
            switch self {
            case .wolfAlerts: return "Emergency alerts and campus safety"
            case .campusEvents: return "Events and activities on campus"
            case .athletics: return "Game updates and scores"
            case .news: return "University news and announcements"
            }
        }

        var icon: String {
            switch self {
            case .wolfAlerts: return "exclamationmark.triangle.fill"
            case .campusEvents: return "calendar"
            case .athletics: return "sportscourt.fill"
            case .news: return "newspaper.fill"
            }
        }

        var color: String {
            switch self {
            case .wolfAlerts: return "red"
            case .campusEvents: return "blue"
            case .athletics: return "green"
            case .news: return "orange"
            }
        }

        var isRequired: Bool {
            self == .wolfAlerts
        }
    }

    private let subscriptionsKey = "notification.subscriptions"

    private(set) var subscribedTopics: Set<Topic> = []

    private init() {
        loadSubscriptions()
    }

    // MARK: - Authorization

    @MainActor
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    @MainActor
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])

            await checkAuthorizationStatus()

            if granted {
                await registerForRemoteNotifications()
                await subscribeToRequiredTopics()
            }

            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Topic Management

    func isSubscribed(to topic: Topic) -> Bool {
        subscribedTopics.contains(topic)
    }

    func subscribe(to topic: Topic) {
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }

        Messaging.messaging().subscribe(toTopic: topic.rawValue) { [weak self] error in
            if let error {
                print("Failed to subscribe to \(topic.rawValue): \(error)")
            } else {
                self?.subscribedTopics.insert(topic)
                self?.saveSubscriptions()
            }
        }
    }

    func unsubscribe(from topic: Topic) {
        guard !topic.isRequired else { return }

        Messaging.messaging().unsubscribe(fromTopic: topic.rawValue) { [weak self] error in
            if let error {
                print("Failed to unsubscribe from \(topic.rawValue): \(error)")
            } else {
                self?.subscribedTopics.remove(topic)
                self?.saveSubscriptions()
            }
        }
    }

    func toggleSubscription(for topic: Topic) {
        if isSubscribed(to: topic) {
            unsubscribe(from: topic)
        } else {
            subscribe(to: topic)
        }
    }

    private func subscribeToRequiredTopics() async {
        for topic in Topic.allCases where topic.isRequired {
            subscribe(to: topic)
        }
    }

    // MARK: - Persistence

    private func loadSubscriptions() {
        let saved = UserDefaults.standard.stringArray(forKey: subscriptionsKey) ?? []
        subscribedTopics = Set(saved.compactMap { Topic(rawValue: $0) })

        // Always include required topics
        for topic in Topic.allCases where topic.isRequired {
            subscribedTopics.insert(topic)
        }
    }

    private func saveSubscriptions() {
        let values = subscribedTopics.map(\.rawValue)
        UserDefaults.standard.set(values, forKey: subscriptionsKey)
    }
}
