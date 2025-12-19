//
//  HeroHeaderView.swift
//  CampusApp
//
//  Created by Jared Tamulynas on 12/17/25.
//

import SwiftUI

struct HeroHeaderView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HeroImageView(imageUrl: nil)

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

                HeaderInfoView(style: .hero)
            }
            .padding()
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
}

#Preview {
    ScrollView {
        HeroHeaderView()
    }
    .ignoresSafeArea(edges: .top)
    .environment(CampusManager())
    .environment(WeatherViewModel())
}
