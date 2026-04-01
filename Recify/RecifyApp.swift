//
//  RecifyApp.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import SwiftUI
import FirebaseCore

@main
struct RecifyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var authManager = AuthManager()
    
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var firebaseViewModel = FirebaseViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView()
                } else if authManager.isAuthenticated {
                    TabBarView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authManager)
            .environmentObject(homeViewModel)
            .environmentObject(firebaseViewModel)
        }
    }
}
