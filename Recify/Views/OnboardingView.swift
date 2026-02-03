//
//  OnboardingView.swift
//  Recify
//
//  Created by mac on 2026-02-02.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    let pages = OnboardingPage.pages
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Recify")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Spacer()
                    
                    Button("Skip") {
                        hasSeenOnboarding = true
                    }
                    .foregroundColor(.gray)
                }
                .padding()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                VStack(spacing: 16) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            hasSeenOnboarding = true
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        Button("Log In") {
                            hasSeenOnboarding = true
                        }
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 24)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
