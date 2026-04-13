//
//  OnboardingPageView.swift
//  Recify
//
//  Created by mac on 2026-02-02.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("onBordingPageImage")
                .resizable()
                .clipShape(.circle)
                .scaledToFit()
                .frame(width: 450, height: 450)
                .shadow(color: .pink.opacity(0.2), radius: 12, x: 0, y: 6)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView(page: OnboardingPage.pages[0])
    }
}
