//
//  CookingModeTabView.swift
//  Recify
//
//  Created by mac on 2026-03-07.
//

import SwiftUI

struct CookingModeTabView: View {
    let recipeTitle: String
    let steps: [String]
    let imageURL: String?
    
    @Environment(\.dismiss) var dismiss
    @State private var currentStepIndex = 0
    
    // MARK: - FIX 1: Clamped Progress
    var progress: Double {
        guard !steps.isEmpty else { return 0.0 }
        let calculatedProgress = Double(currentStepIndex + 1) / Double(steps.count)
        return min(max(calculatedProgress, 0.0), 1.0)
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
                    
                    if !steps.isEmpty {
                        Text("Step \(currentStepIndex + 1) of \(steps.count)")
                            .font(.caption)
                            .foregroundColor(.pink)
                            .fontWeight(.semibold)
                    } else {
                        Text("No steps")
                            .font(.caption)
                            .foregroundColor(.pink)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(Color.white)
            
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    //Handle Base64 Custom Images AND API URLs
                    if let imageString = imageURL {
                        if imageString.hasPrefix("http"),
                           let safeURLString = imageString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: safeURLString) {
                            
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                case .failure:
                                    placeholderImage
                                @unknown default:
                                    placeholderImage
                                }
                            }
                        } else if let imageData = Data(base64Encoded: imageString),
                                  let uiImage = UIImage(data: imageData) {
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(12)
                                .padding(.horizontal)
                        } else {
                            placeholderImage
                        }
                    } else {
                        placeholderImage
                    }
                    
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
        .navigationBarBackButtonHidden(true)
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
    
    private var placeholderImage: some View {
        Image(systemName: "fork.knife.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .foregroundColor(.pink.opacity(0.3))
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

struct CookingModeTabView_Previews: PreviewProvider {
    static var previews: some View {
        CookingModeTabView(
            recipeTitle: "Strawberry Crepes",
            steps: [
                "In a medium bowl, whisk together the large eggs, whole milk, and melted butter until the mixture is light and bubbly.",
                "In another bowl, sift together the all-purpose flour, granulated sugar, and a pinch of salt."
            ],
            imageURL: "https://example.com/placeholder.jpg"
        )
    }
}
