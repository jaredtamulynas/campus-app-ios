//
//  GuidesViewModel.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 11/3/25.
//

import Foundation

@Observable
final class GuidesViewModel {
    private let service: GuidesServiceProtocol
    
    var guidesData: GuidesData?
    var state: LoadState = .loading
    
    init(service: GuidesServiceProtocol = GuidesService()) {
        self.service = service
    }
    
    @MainActor
    func loadGuides() async {
        state = .loading
        
        do {
            guidesData = try await service.fetchGuides()
            state = .loaded
        } catch {
            state = .error(error)
        }
    }
    
    func visibleGuides(for perspective: PerspectiveType?) -> [Guide] {
        guard let perspective = perspective else { return [] }
        return guidesData?.visibleGuides(for: perspective) ?? []
    }
}
