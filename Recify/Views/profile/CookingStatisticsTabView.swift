//
//  CookingStatisticsTabView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct CookingStatisticsTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
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
                    
                    Text("Level 12 Master Cook")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                    
                    Text("Shining since Jan 2024")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.pink)
                            Text("Recipes")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("124")
                            .font(.title)
                            .fontWeight(.bold)
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("+12% this month")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.pink)
                            Text("Cooking")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("12 days")
                            .font(.title)
                            .fontWeight(.bold)
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("On fire!")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cuisines Explored")
                        .font(.headline)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.pink.opacity(0.2), lineWidth: 30)
                            .frame(width: 150, height: 150)
                        
                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(Color.pink, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("12")
                                .font(.system(size: 36, weight: .bold))
                            Text("types")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Pantry Efficiency")
                            .font(.headline)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("SAVED $40")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                            Text("vs last month")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        Text("85%")
                            .font(.system(size: 48, weight: .bold))
                        Spacer()
                    }
                    
                    Text("Resource Utilization")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ProgressView(value: 0.85)
                        .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("*You're excellent at using on-hand ingredients! This month you've wasted 12% less fresh produce.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Weekly Heatmap")
                            .font(.headline)
                        Spacer()
                        HStack(spacing: 8) {
                            Text("LESS ACTIVE")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            HStack(spacing: 2) {
                                Circle().fill(Color.pink.opacity(0.2)).frame(width: 8, height: 8)
                                Circle().fill(Color.pink.opacity(0.4)).frame(width: 8, height: 8)
                                Circle().fill(Color.pink.opacity(0.6)).frame(width: 8, height: 8)
                                Circle().fill(Color.pink.opacity(0.8)).frame(width: 8, height: 8)
                                Circle().fill(Color.pink).frame(width: 8, height: 8)
                            }
                            Text("MORE ACTIVE")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                        ForEach(0..<49) { index in
                            Rectangle()
                                .fill(Color.pink.opacity(Double.random(in: 0.2...1.0)))
                                .frame(height: 20)
                                .cornerRadius(4)
                        }
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
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {}) {
//                    Image(systemName: "square.and.arrow.up")
//                        .foregroundColor(.pink)
//                }
//            }
//        }
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
