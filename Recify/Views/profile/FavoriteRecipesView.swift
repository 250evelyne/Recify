//
//  FavoriteRecipesView.swift
//  Recify
//
//  Created by netblen on 09-03-2026.
//

import SwiftUI

struct FavoriteRecipesView: View {
    @StateObject var firebaseManager = FirebaseViewModel.shared
    let mockRecipes = [
        SavedRecipe(mealId: "1", title: "Spaghetti Carbonara", imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"),
        SavedRecipe(mealId: "2", title: "Chicken Tikka Masala", imageURL: "https://www.themealdb.com/images/media/meals/uuuspp1511297945.jpg"),
        SavedRecipe(mealId: "3", title: "Beef Tacos", imageURL: "https://www.themealdb.com/images/media/meals/birtwx1438941521.jpg"),
        SavedRecipe(mealId: "4", title: "Margherita Pizza", imageURL: "https://www.themealdb.com/images/media/meals/x0lk931587671539.jpg"),
    ]
    
    var body: some View {
        ScrollView {
            //check if we have saved recipes or use mock data for testing
            let recipesToDisplay = firebaseManager.savedRecipes.isEmpty ? mockRecipes : firebaseManager.savedRecipes
            
            if recipesToDisplay.isEmpty {
                emptyStateView
            } else {
                recipesGrid(recipes: recipesToDisplay)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Favorite Recipes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //ensures the page always grabs the latest favorites 
            firebaseManager.fetchSavedRecipes()
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the heart icon on any recipe to save it here for later!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 100)
    }
    
    private func recipesGrid(recipes: [SavedRecipe]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
            spacing: 16
        ) {
            ForEach(recipes) { recipe in
                
                let placeholderRecipe = Recipe(
                    id: recipe.mealId,
                    title: recipe.title,
                    category: "General",
                    ingredients: [],
                    instructions: "",
                    imageURL: recipe.imageURL,
                    servings: 1,
                    userId: "",
                    inPantry: false,
                    prepTime: 30,
                    calories: 0,
                    level: "Medium"
                )
                
                NavigationLink(destination: RecipeInstructionsView(
                    mealId: recipe.mealId,
                    recipeTitle: recipe.title,
                    recipeImage: recipe.imageURL,
                    prepTime: 30,
                    difficulty: "Medium"
                )) {
                    RecipeCard(
                        title: recipe.title,
                        imageURL: recipe.imageURL,
                        time: "30m",
                        difficulty: "Medium",
                        //rating: 4.8,
                        matchPercentage: nil,
                        recipe: placeholderRecipe
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
}

struct FavoriteRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FavoriteRecipesView()
        }
    }
}
