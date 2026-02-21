//
//  CookingModeTabView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct CookingModeTabView: View {
    @State private var currentStep: Int = 3
    let totalSteps: Int = 8
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OVERALL PROGRESS")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        ProgressView(value: Double(currentStep), total: Double(totalSteps))
                            .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                        
                        Text("Step \(currentStep) of \(totalSteps)")
                            .font(.caption)
                            .foregroundColor(.pink)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.pink.opacity(0.3))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STEP \(currentStep)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                            
                            Text("Whisk the wet ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("In a medium bowl, whisk together the large eggs, whole milk, and melted butter until the mixture is light and bubbly.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.pink)
                            Text("Voice Commands")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Say 'Next' to skip steps")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Image(systemName: "waveform")
                                .foregroundColor(.pink)
                        }
                        .padding()
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(12)
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.pink)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Text("Next Step")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.pink)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Cooking: Strawberry Crepes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.pink)
                    }
                }
            }
        }
    }
}

struct CookingModeTabView_Previews: PreviewProvider {
    static var previews: some View {
        CookingModeTabView()
    }
}
