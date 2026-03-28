//
//  FavoriteRecipesView.swift
//  Recify
//
//  Created by netblen on 09-03-2026.
//

import SwiftUI

struct FavoriteRecipesView: View {
    @StateObject var firebaseManager = FirebaseViewModel.shared
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
    let recipes : [String]
    
    @State var isFavorite : Bool = true //TODO:fecth from firebase if the recipi is in thier favories (anabella)
    
    var body: some View {
        VStack{
            ScrollView {
//                Empty State
                if firebaseManager.currentCollectionRecipes.isEmpty {
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
                    
                } else {
                    
                    ForEach(recipes, id: \.self){ recipeId in
                        RecipeCollectionRow(recipeId: recipeId)
                    }
                }
            }
            .navigationTitle(collectionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                //ensures the page always grabs the latest favorites
                firebaseManager.fetchRecipesForCollection(ids: recipes)
            }
        }
    }
}
    
    
    
    struct RecipeCollectionRow: View {
        let recipeId: String
        
        var body: some View {
            if let fullRecipe = FirebaseViewModel.shared.currentCollectionRecipes.first(where: { $0.id == recipeId }) {
                searchResultCard(
                    mealId: recipeId,
                    title: fullRecipe.title,
                    imageURL: fullRecipe.imageUrl ?? "", //TODO: make sure it shows somthing if the imag dosnt load
                    time: fullRecipe.prepTime,
//                    difficulty: fullRecipe.dificulty?.rawValue ?? "N/A",
                    difficulty: fullRecipe.level
//                    isFavorite: true
                )
            } else {
                HStack {
                    ProgressView()
                    Text("Loading recipe details...")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .padding()
        }
    }
}
    
struct FavoriteRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FavoriteRecipesView(
                collectionTitle: "wine dinner", recipes: ["1"]
            )
        }
    }
}

