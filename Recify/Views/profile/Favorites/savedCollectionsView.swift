//
//  savedCollectionsView.swift
//  Recify
//
//  Created by Macbook on 2026-03-10.
//

import SwiftUI

struct savedCollectionsView: View {
    @StateObject var firebaseManager = FirebaseViewModel.shared
    let mockRecipes: [Recipe] = [
        Recipe(
            id: "1",
            title: "Spaghetti Carbonara",
            category: "Pasta",
            ingredients: [
                "Spaghetti",
                "Eggs",
                "Parmesan Cheese",
                "Pancetta",
                "Black Pepper"
            ],
            instructions: [
                "Cook spaghetti in salted boiling water.",
                "Fry pancetta until crispy.",
                "Whisk eggs and parmesan together.",
                "Combine pasta with pancetta and egg mixture.",
                "Serve with black pepper."
            ],
            servings: 4,
            timeMinutes: 25,
            userId: "mockUser",
            //difficulty: Difficulty.easy
        ),

        Recipe(
            id: "2",
            title: "Chicken Tikka Masala",
            category: "Curry",
            ingredients: [
                "Chicken Breast",
                "Yogurt",
                "Garlic",
                "Ginger",
                "Tomato Sauce",
                "Cream"
            ],
            instructions: [
                "Marinate chicken in yogurt and spices.",
                "Grill or pan cook the chicken.",
                "Prepare tomato cream sauce.",
                "Add chicken to sauce and simmer.",
                "Serve with rice."
            ],
            servings: 4,
            timeMinutes: 40,
            userId: "mockUser",
            //difficulty: Difficulty.hard
        ),

        Recipe(
            id: "3",
            title: "Avocado Toast",
            category: "Breakfast",
            ingredients: [
                "Bread",
                "Avocado",
                "Salt",
                "Black Pepper",
                "Lemon Juice"
            ],
            instructions: [
                "Toast the bread.",
                "Mash avocado with lemon juice.",
                "Spread avocado on toast.",
                "Season with salt and pepper."
            ],
            servings: 1,
            timeMinutes: 10,
            userId: "mockUser",
            //difficulty: Difficulty.easy
        )
    ]
    
//    var mockCollections: [RecipeCollection] {
//        [
//            RecipeCollection(
//                name: "Weeknight Dinners",
//                imageurl: "https://picsum.photos/400",
//                recipes: ["1"]
//            ),
//            RecipeCollection(
//                name: "Weekend lunch",
//                imageurl: "https://picsum.photos/400",
//                recipes: ["1"]
//            )
//        ]
//    }
    
    //for the lazy v grid
    let colums = [GridItem(.flexible()), GridItem(.flexible())]
    
    @Environment(\.dismiss) var dissmiss
    
    var body: some View {
        NavigationStack{
            VStack{
                
                ScrollView {
                    //Empty State
                    if firebaseManager.userFavCollections.isEmpty {
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
                        // MARK: - Saved Recipes Grid
                        LazyVGrid(columns: colums, spacing: 20) {
                            //                        ForEach(mockCollections, id: \.id) { collection in
                            ForEach(firebaseManager.userFavCollections) { collection in
                                
                                saveFolderView(imageurl: collection.imageUrl, countRecipes: collection.recipeIds.count, name: collection.name, recipes: collection.recipeIds)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Collections")
            
            .navigationBarTitleDisplayMode(.large)
            //        .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: CreateCollection()) {
                        Image(systemName: "plus")
                            .padding(10)
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.blue)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dissmiss()
                    } label: {
                        Image(systemName: "carrot.fill")
                            .padding(10)
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.blue)
                            .bold()
                    }
                    
                }
                
            }
            .onAppear {
                firebaseManager.fecthUsersCollections()
            }
        }
    }
        
}


struct saveFolderView : View {
    var imageurl : String
    var countRecipes : Int
    var name : String
    var recipes : [String] //TODO: either we get the recipes here or in the next page (anabella or me)
    
    var body: some View {
        
        NavigationLink(destination: FavoriteRecipesView(collectionTitle: name, recipes: recipes)) {
            
            VStack(alignment: .leading){
                
                AsyncImage(url: URL(string: imageurl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 400)
                    @unknown default:
                        EmptyView()
                    }
                }.overlay(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 18)
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(width: 85, height: 25)
                        .padding()
                        .overlay {
                            Text("\(countRecipes) ITEMS")
                                .foregroundStyle(.white)
                                .font(.system(size: 15))
                        }
                }
                
                Text(name)
                    .bold()
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    savedCollectionsView()
}
