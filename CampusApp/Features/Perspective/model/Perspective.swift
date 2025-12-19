//
//  Perspective.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/27/25.
//

import Foundation

// MARK: - Perspective Type Enum

enum PerspectiveType: String, Codable, CaseIterable, Identifiable {
    case guest = "guest"
    case student = "student"
    case graduate = "graduate"
    case parent = "parent"
    case facultyStaff = "facultyStaff"
    
    var id: String { rawValue }
    
    var displayInfo: Perspective {
        switch self {
        case .guest:
            return Perspective(
                type: .guest,
                title: "Guest / Prospective",
                description: "Exploring NC State? See what we offer.",
                systemImage: "person.fill.questionmark"
            )
        case .student:
            return Perspective(
                type: .student,
                title: "Student",
                description: "Access classes, dining, transit, and more.",
                systemImage: "graduationcap.fill"
            )
        case .graduate:
            return Perspective(
                type: .graduate,
                title: "Graduate Student",
                description: "Find research tools and grad resources.",
                systemImage: "books.vertical.fill"
            )
        case .parent:
            return Perspective(
                type: .parent,
                title: "Parent",
                description: "Stay connected with campus life and events.",
                systemImage: "person.2.fill"
            )
        case .facultyStaff:
            return Perspective(
                type: .facultyStaff,
                title: "Faculty & Staff",
                description: "Campus services, HR, and internal tools.",
                systemImage: "briefcase.fill"
            )
        }
    }
}

// MARK: - Perspective Display Info

struct Perspective: Identifiable {
    let type: PerspectiveType
    let title: String
    let description: String
    let systemImage: String
    
    var id: String { type.rawValue }
}

// MARK: - Perspective Visibility

struct PerspectiveVisibility: Codable, Equatable {
    let perspectives: [PerspectiveType]
    
    init(perspectives: [PerspectiveType]) {
        self.perspectives = perspectives
    }
    
    /// Check if content is visible for the given perspective
    func isVisible(for perspective: PerspectiveType) -> Bool {
        perspectives.contains(perspective)
    }
    
    // MARK: - Convenience Initializers
    
    /// Visible to all perspectives
    static let all = PerspectiveVisibility(perspectives: PerspectiveType.allCases)
    
    /// Visible only to students (both undergrad and grad)
    static let studentsOnly = PerspectiveVisibility(perspectives: [.student, .graduate])
    
    /// Visible to everyone except guests
    static let authenticated = PerspectiveVisibility(
        perspectives: [.student, .graduate, .parent, .facultyStaff]
    )
    
    /// Visible only to guests (prospective students)
    static let guestsOnly = PerspectiveVisibility(perspectives: [.guest])
}
