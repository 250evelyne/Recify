//
//  GradientBackgound.swift
//  Recify
//
//  Created by mac on 2026-04-12.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 1.0),
                Color(red: 0.85, green: 0.93, blue: 1.0),
                Color(red: 1.0, green: 0.90, blue: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

extension View {
    func recifyBackground() -> some View {
        ZStack {
            GradientBackground()
            self
        }
    }
}
