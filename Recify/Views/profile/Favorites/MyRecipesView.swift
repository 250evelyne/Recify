//
//  MyRecipesView.swift
//  Recify
//
//  Created by Macbook on 2026-03-27.
//

import SwiftUI


struct MyRecipesView: View {
    @ObservedObject var firebaseManager = FirebaseViewModel.shared
        
        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.1),
                        Color.clear,
                        Color.pink.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        if firebaseManager.userRecipes.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.4))
                                
                                Text("No Recipes Yet 👩‍🍳")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, 100)
                            
                        } else {
                            ForEach(firebaseManager.userRecipes) { recipe in
                                MyRecipeRow(recipe: recipe)
                            }
                        }
                    }
                    .navigationTitle("My Recipes")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        Task {
                            await firebaseManager.loadUserRecipes()
                        }
                    }
                }
            }
        }
}

struct MyRecipeRow: View {
    let recipe: Recipe
    @ObservedObject var firebaseManager = FirebaseViewModel.shared
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationLink(destination: RecipeInstructionsView(
            mealId: recipe.id ?? "",
            recipeTitle: recipe.title,
            recipeImage: recipe.imageURL ?? "",
            prepTime: recipe.prepTime,
            difficulty: recipe.level
        )) {
            searchResultCard(
                mealId: recipe.id ?? "",
                title: recipe.title,
                imageURL: recipe.imageURL ?? "",
                time: recipe.prepTime,
                difficulty: recipe.level,
                height: 200
            )
        }
        .buttonStyle(.plain)
        
        .contextMenu {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Recipe", systemImage: "trash")
            }
        }
        .alert("Delete Recipe?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteRecipe()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func deleteRecipe() {
        guard let id = recipe.id else { return }
        firebaseManager.deleteRecipe(recipeId: id)
    }
}

#Preview {
    MyRecipesView()
}
