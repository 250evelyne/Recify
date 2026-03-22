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
            //Empty State
//            if firebaseManager.savedRecipes.isEmpty {
//                VStack(spacing: 16) {
//                    Image(systemName: "heart.slash")
//                        .font(.system(size: 60))
//                        .foregroundColor(.gray.opacity(0.4))
//                    
//                    Text("No Favorites Yet")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    
//                    Text("Tap the heart icon on any recipe to save it here for later!")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.top, 100)
                
            //} else {
                // MARK: - Saved Recipes Grid
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                    spacing: 16
                ) {
                    //ForEach(firebaseManager.savedRecipes) { recipe in
                    ForEach(mockRecipes) { recipe in
                        NavigationLink(destination: RecipeInstructionsView(
                            mealId: recipe.mealId,
                            recipeTitle: recipe.title,
                            recipeImage: recipe.imageURL
                        )) {
                            RecipeCard(
                                title: recipe.title,
                                imageURL: recipe.imageURL,
                                time: "30m",
                                difficulty: "Medium",
                                rating: 4.8,
                                matchPercentage: nil
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            //}
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Favorite Recipes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //ensures the page always grabs the latest favorites 
            firebaseManager.fetchSavedRecipes()
        }
    }
}

struct FavoriteRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FavoriteRecipesView()
        }
    }
}
