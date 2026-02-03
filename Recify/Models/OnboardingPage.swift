//
//  OnBoardingPage.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

extension OnboardingPage {
    static let pages = [
        OnboardingPage(
            title: "Welcome to Recify",
            description: "Turn your pantry staples into delicious meals instantly. Your kitchen, reimagined."
        ),
        OnboardingPage(
            title: "Smart Pantry Manager",
            description: "Track your ingredients and never waste food again."
        ),
        OnboardingPage(
            title: "Personalized Recipes",
            description: "Get recipe suggestions based on what you have at home."
        )
    ]
}
