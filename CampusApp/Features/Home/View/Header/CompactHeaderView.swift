//
//  CompactHeaderView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct CompactHeaderView: View {
    var body: some View {
        HeaderInfoView(style: .compact)
            .font(.caption)
            .padding()
            .background(.ultraThinMaterial)
    }
}

#Preview {
    CompactHeaderView()
        .environment(CampusManager())
        .environment(WeatherViewModel())
}
