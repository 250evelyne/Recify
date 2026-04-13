//
//  CookingStatisticsTabView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct CookingStatisticsTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var firebaseViewModel = FirebaseViewModel.shared
    
    var joinedDateString: String {
        guard let date = authManager.userProfile?.createdAt else { return "Jan 2024" }
        return date.formatted(.dateTime.month().year())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Profile Header
                VStack(spacing: 12) {
                    Image(authManager.userProfile?.avatar ?? "cupcakeAvatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        .overlay(
                            Circle()
                                .fill(Color.pink)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 28, y: 28)
                        )
                    
                    Text(authManager.userProfile?.userName ?? "Chef")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Shining since \(joinedDateString)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                
                // MARK: - Quick Stats
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.pink)
                            Text("Published")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("\(firebaseViewModel.userRecipes.count)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.pink)
                            Text("Cooked")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("\(authManager.userProfile?.mealsCooked ?? 0) times")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // MARK: - Saved Recipes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recipes Saved")
                        .font(.headline)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.pink.opacity(0.2), lineWidth: 30)
                            .frame(width: 150, height: 150)
                        
                        Circle()
                            .trim(from: 0, to: min(CGFloat(firebaseViewModel.savedRecipes.count) / 50.0, 1.0))
                            .stroke(Color.pink, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 1.0), value: firebaseViewModel.savedRecipes.count)
                        
                        VStack {
                            Text("\(firebaseViewModel.savedRecipes.count)")
                                .font(.system(size: 36, weight: .bold))
                            Text("saved")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // MARK: - Pantry Items
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Pantry Status")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack(alignment: .bottom) {
                        Text("\(firebaseViewModel.ingredients.count)")
                            .font(.system(size: 48, weight: .bold))
                        
                        Text("items stocked")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Cooking Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await firebaseViewModel.loadUserRecipes()
            }
            firebaseViewModel.fetchSavedRecipes()
            firebaseViewModel.fetchIngredients()
        }
    }
}

struct CookingStatisticsTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CookingStatisticsTabView()
                .environmentObject(AuthManager())
        }
    }
}
