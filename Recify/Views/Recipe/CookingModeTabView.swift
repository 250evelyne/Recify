//
//  CookingModeTabView.swift
//
//  CalendarView.swift
//  Recify
//
//  Created by mac on 2026-03-07.
//

import SwiftUI

struct CookingModeTabView: View {
    let recipeTitle: String
    let steps: [String]
    
    @Environment(\.dismiss) var dismiss
    @State private var currentStepIndex = 0
    
    var progress: Double {
        Double(currentStepIndex + 1) / Double(steps.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("OVERALL PROGRESS")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                    
                    Text("Step \(currentStepIndex + 1) of \(steps.count)")
                        .font(.caption)
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color.white)
            
            
            ScrollView {
                VStack(spacing: 20) {
                    // TODO: Recipe IMG
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.pink.opacity(0.3))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                                        
                    VStack(alignment: .leading, spacing: 8) {
                        if steps.indices.contains(currentStepIndex) {
                            
                            Text("STEP \(currentStepIndex + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                            
                            Text(steps[currentStepIndex])
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineSpacing(6)
                        } else {
                            Text("No steps available")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                }
            }
            
            
            HStack(spacing: 16) {
                Button(action: {
                    if currentStepIndex > 0 {
                        withAnimation {
                            currentStepIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(currentStepIndex > 0 ? .pink : .gray)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                }
                .disabled(currentStepIndex == 0)
                
                Button(action: {
                    if currentStepIndex < steps.count - 1 {
                        withAnimation {
                            currentStepIndex += 1
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    HStack {
                        Text(currentStepIndex < steps.count - 1 ? "Next Step" : "Finish Cooking")
                            .fontWeight(.semibold)
                        Image(systemName: currentStepIndex < steps.count - 1 ? "arrow.right" : "checkmark")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
                }
            }
            
            .padding()
            
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Cooking: \(recipeTitle)")
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) //should take off the double back bttn
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { 
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.pink)
                }
            }
        }
        
    }
}

struct CookingModeTabView_Previews: PreviewProvider {
    static var previews: some View {
        CookingModeTabView(
            recipeTitle: "Strawberry Crepes",
            steps: [
                "In a medium bowl, whisk together the large eggs, whole milk, and melted butter until the mixture is light and bubbly.",
                "In another bowl, sift together the all-purpose flour, granulated sugar, and a pinch of salt.",
                "Gradually add the dry ingredients to the wet ingredients, whisking constantly to avoid lumps.",
                "Heat a non-stick pan over medium heat and lightly grease with butter.",
                "Pour a small amount of batter into the pan and swirl to coat evenly.",
                "Cook for 1-2 minutes until the edges start to lift, then flip and cook for another 30 seconds.",
                "Transfer to a plate and fill with fresh strawberries and whipped cream.",
                "Fold the crepe and dust with powdered sugar. Serve immediately."
            ]
        )
    }
}
