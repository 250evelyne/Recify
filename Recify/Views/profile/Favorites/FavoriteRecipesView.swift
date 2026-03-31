//
//  FavoriteRecipesView.swift
//  Recify
//
//  Created by netblen on 09-03-2026.
//

import SwiftUI

struct FavoriteRecipesView: View {
    @ObservedObject var firebaseManager = FirebaseViewModel.shared
    //    let mockRecipes = [
    //        SavedRecipe(mealId: "1", title: "Spaghetti Carbonara", imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"),
    //        SavedRecipe(mealId: "2", title: "Chicken Tikka Masala", imageURL: "https://www.themealdb.com/images/media/meals/uuuspp1511297945.jpg"),
    //        SavedRecipe(mealId: "3", title: "Beef Tacos", imageURL: "https://www.themealdb.com/images/media/meals/birtwx1438941521.jpg"),
    //        SavedRecipe(mealId: "4", title: "Margherita Pizza", imageURL: "https://www.themealdb.com/images/media/meals/x0lk931587671539.jpg"),
    //    ]
    
    //    let title: String
    //    let imageURL: String
    //    let time: Int
    //    let difficulty: String
    
    let collectionTitle: String
    //let recipes : [String]
    
    var recipes: [String] {
        let rawList: [String]
        
        if collectionTitle == "Liked Recipes" {
            rawList = firebaseManager.savedRecipes.map { $0.mealId }
        } else {
            rawList = firebaseManager.userFavCollections.first(where: { $0.name == collectionTitle })?.recipeIds ?? []
        }
        
        var uniqueRecipes: [String] = []
        for id in rawList {
            if !uniqueRecipes.contains(id) {
                uniqueRecipes.append(id)
            }
        }
        
        return uniqueRecipes
    }
    
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
                    //                Empty State
                    if recipes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            
                            Text("No Favorites Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 100)
                        
                    } else {
                        
                        ForEach(recipes, id: \.self) { recipeId in
                            RecipeCollectionRow(recipeId: recipeId, collectionTitle: collectionTitle)
                        }
                    }
                }
                .navigationTitle(collectionTitle)
                .navigationBarTitleDisplayMode(.inline)
//                .background(Color.white)
                .onAppear {
                    if !recipes.isEmpty {
                        firebaseManager.fetchRecipesForCollection(ids: recipes)
                    }
                }
                //ftch again if the recipes list changes while looking at the view
                .onChange(of: recipes) { newRecipes in
                    if !newRecipes.isEmpty {
                        firebaseManager.fetchRecipesForCollection(ids: newRecipes)
                    }
                }
            }
        }
    }
}
    
    
    
struct RecipeCollectionRow: View {
    let recipeId: String
    let collectionTitle: String
    @ObservedObject var firebaseManager = FirebaseViewModel.shared
    
    var body: some View {
        if let savedRecipe = firebaseManager.currentCollectionRecipes.first(where: { $0.mealId == recipeId }) {
            NavigationLink(destination: RecipeInstructionsView(
                mealId: savedRecipe.mealId,
                recipeTitle: savedRecipe.title,
                recipeImage: savedRecipe.imageURL,
                prepTime: 30,
                difficulty: "Easy"
            )) {
                searchResultCard(
                    mealId: savedRecipe.mealId,
                    title: savedRecipe.title,
                    imageURL: savedRecipe.imageURL,
                    time: 30,
                    difficulty: "Easy",
                    height: 200
                )
            }
            .buttonStyle(.plain)
            .contextMenu {
                if collectionTitle != "Liked Recipes" {
                    Button(role: .destructive) {
                        firebaseManager.removeFromCollection(recipeId: recipeId, collectionTitle: collectionTitle)
                    } label: {
                        Label("Remove from Collection", systemImage: "folder.badge.minus")
                    }
                }
                
                Button(role: .destructive) {
                    firebaseManager.toggleFavorite(mealId: savedRecipe.mealId, title: savedRecipe.title, imageURL: savedRecipe.imageURL)
                } label: {
                    Label("Unlike Completely", systemImage: "heart.slash")
                }
            }
        } else {
            // "0 count" fallback
            HStack {
                Image(systemName: "heart.slash.fill")
                    .foregroundColor(.gray)
                Text("Recipe removed from favorites")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button("Clean up") {
                    firebaseManager.removeFromCollection(recipeId: recipeId, collectionTitle: collectionTitle)
                }
                .font(.caption)
                .foregroundColor(.pink)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
    
struct FavoriteRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FavoriteRecipesView(collectionTitle: "wine dinner")
        }
    }
}

