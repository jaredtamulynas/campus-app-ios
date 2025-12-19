//
//  ViewModifiers.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 12/15/25.
//

import SwiftUI

enum PillStyle {
    case material
}

struct Pill: ViewModifier {
    let style: PillStyle

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .material:
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}


extension View {
    func pill(_ style: PillStyle) -> some View {
        modifier(Pill(style: style))
    }
}

