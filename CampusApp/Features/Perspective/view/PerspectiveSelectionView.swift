//
//  PerspectiveSelectionView.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI

struct PerspectiveSelectionView: View {
    @Environment(CampusManager.self) private var campusManager
    @Environment(UserSettings.self) private var userSettings
    
    let perspectives = PerspectiveType.allCases.map { $0.displayInfo }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(perspectives) { p in
                    Button {
                        userSettings.setPerspective(p.type)
                    } label: {
                        HStack {
                            Image(systemName: p.systemImage)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.accent)
                            
                            VStack(alignment: .leading) {
                                Text(p.title)
                                    .font(.headline)
                                Text(p.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if userSettings.selectedPerspective == p.type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Choose Your Perspective")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    PerspectiveSelectionView()
        .environment(CampusManager())
        .environment(UserSettings())
}
