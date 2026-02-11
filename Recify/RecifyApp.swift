//
//  RecifyApp.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import SwiftUI
import FirebaseCore

/*
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions lunchOptions : [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}*/


@main
struct RecifyApp: App {
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
