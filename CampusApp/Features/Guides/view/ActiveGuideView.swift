//
//  ActiveGuideView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/24/25.
//

import SwiftUI

/// A step-by-step walkthrough view for guide sections
/// Provides a focused, full-screen experience for reading through guide content
struct ActiveGuideView: View {
    let guide: Guide
    @State private var currentSectionIndex = 0
    @State private var viewedSections: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    @Environment(UserSettings.self) private var userSettings
    
    private var sortedSections: [GuideSection] {
        guide.sections?.sorted(by: { $0.order < $1.order }) ?? []
    }
    
    private var currentSection: GuideSection? {
        guard currentSectionIndex < sortedSections.count else { return nil }
        return sortedSections[currentSectionIndex]
    }
    
    private var progress: Double {
        guard !sortedSections.isEmpty else { return 0 }
        return Double(viewedSections.count) / Double(sortedSections.count)
    }
    
    private var guideColor: Color {
        colorForName(guide.color)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                progressBar
                
                // Current Section Content
                if let section = currentSection {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            sectionHeader(section)
                            
                            Text(section.content)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    
                    // Navigation Buttons
                    navigationButtons(for: section)
                } else if sortedSections.isEmpty {
                    noSectionsView
                } else {
                    completionView
                }
            }
            .navigationTitle(guide.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                userSettings.markGuideStarted(guide.id)
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Section \(currentSectionIndex + 1) of \(sortedSections.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))% Complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            ProgressView(value: progress)
                .tint(guideColor)
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(_ section: GuideSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(guideColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    if viewedSections.contains(section.id) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(guideColor)
                    } else {
                        Text("\(section.order)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(guideColor)
                    }
                }
                
                Spacer()
            }
            
            Text(section.title)
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    // MARK: - Navigation Buttons
    
    private func navigationButtons(for section: GuideSection) -> some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 12) {
                // Previous Button
                if currentSectionIndex > 0 {
                    Button {
                        withAnimation {
                            currentSectionIndex -= 1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(.primary)
                }
                
                // Next/Complete Button
                Button {
                    markCurrentSectionViewed()
                } label: {
                    HStack {
                        if viewedSections.contains(section.id) {
                            if currentSectionIndex < sortedSections.count - 1 {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            } else {
                                Text("Finish")
                                Image(systemName: "checkmark")
                            }
                        } else {
                            Image(systemName: "checkmark")
                            Text("Mark as Read")
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(guideColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(.regularMaterial)
    }
    
    // MARK: - No Sections View
    
    private var noSectionsView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Sections")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This guide doesn't have walkthrough sections.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Go Back")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(guideColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(guideColor.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(guideColor)
            }
            
            VStack(spacing: 12) {
                Text("All Done!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("You've read through all sections of \(guide.title)")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(guideColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    // MARK: - Actions
    
    private func markCurrentSectionViewed() {
        guard let section = currentSection else { return }
        
        withAnimation {
            viewedSections.insert(section.id)
            
            // Move to next section if available
            if currentSectionIndex < sortedSections.count - 1 {
                currentSectionIndex += 1
            } else {
                // All sections viewed, show completion
                currentSectionIndex = sortedSections.count
            }
        }
    }
    
    // MARK: - Helper
    
    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "teal": return .teal
        case "mint": return .mint
        default: return .blue
        }
    }
}

#Preview {
    ActiveGuideView(
        guide: Guide(
            id: "test",
            title: "Test Guide",
            department: "Test Dept",
            description: "A test guide",
            headerImageUrl: nil,
            icon: "book.fill",
            color: "blue",
            visibility: .all,
            featured: nil,
            alert: nil,
            sections: [
                GuideSection(id: "1", title: "Getting Started", order: 1, content: "Welcome to this guide! This is the first section with important information about getting started."),
                GuideSection(id: "2", title: "Next Steps", order: 2, content: "Now that you've completed the first section, here are the next steps you should take.")
            ],
            events: nil,
            locations: nil,
            todos: nil,
            faqs: nil,
            contacts: nil,
            links: nil,
            updates: nil
        )
    )
    .environment(UserSettings())
}
