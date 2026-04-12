//
//  RecifyApp.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct RecifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var authManager = AuthManager()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var firebaseViewModel = FirebaseViewModel()
    
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
            .environmentObject(ChatManager())
        }
    }
}
