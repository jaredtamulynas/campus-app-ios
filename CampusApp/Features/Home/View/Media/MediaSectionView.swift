//
//  MediaSectionView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct MediaSectionView: View {
    let radioPlayer: RadioPlayerViewModel
    let onTVTap: () -> Void

    var body: some View {
        SectionView("Campus Media") {
            AdaptiveMediaWidgetsView(
                radioPlayer: radioPlayer,
                onTVTap: onTVTap
            )
        }
    }
}

#Preview {
    MediaSectionView(
        radioPlayer: RadioPlayerViewModel.shared,
        onTVTap: {}
    )
}
