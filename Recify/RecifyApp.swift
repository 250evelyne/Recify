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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(authManager)
            } else if authManager.isAuthenticated {
                ProfileView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
