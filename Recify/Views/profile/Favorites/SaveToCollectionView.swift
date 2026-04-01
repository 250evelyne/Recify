//
//  SaveToCollectionView.swift
//  Recify
//
//  Created by Macbook on 2026-03-21.
//

import SwiftUI

struct SaveToCollectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var firebaseVM = FirebaseViewModel.shared
    
    var recipeId: String
    
    @State private var showAlert = false
    @State private var collectionSelected: RecipeCollection? = nil
    
    //let mockRecipes: [Recipe] = [
    //        Recipe(
    //            id: "1",
    //            title: "Spaghetti Carbonara",
    //            category: "Pasta",
    //            ingredients: [
    //                "Spaghetti",
    //                "Eggs",
    //                "Parmesan Cheese",
    //                "Pancetta",
    //                "Black Pepper"
    //            ],
    //            instructions: [
    //                "Cook spaghetti in salted boiling water.",
    //                "Fry pancetta until crispy.",
    //                "Whisk eggs and parmesan together.",
    //                "Combine pasta with pancetta and egg mixture.",
    //                "Serve with black pepper."
    //            ],
    //            servings: 4,
    //            timeMinutes: 25,
    //            userId: "mockUser",
    //            //difficulty: Difficulty.easy
    //        ),
    //
    //        Recipe(
    //            id: "2",
    //            title: "Chicken Tikka Masala",
    //            category: "Curry",
    //            ingredients: [
    //                "Chicken Breast",
    //                "Yogurt",
    //                "Garlic",
    //                "Ginger",
    //                "Tomato Sauce",
    //                "Cream"
    //            ],
    //            instructions: [
    //                "Marinate chicken in yogurt and spices.",
    //                "Grill or pan cook the chicken.",
    //                "Prepare tomato cream sauce.",
    //                "Add chicken to sauce and simmer.",
    //                "Serve with rice."
    //            ],
    //            servings: 4,
    //            timeMinutes: 40,
    //            userId: "mockUser",
    //            //difficulty: Difficulty.hard
    //        ),
    //
    //        Recipe(
    //            id: "3",
    //            title: "Avocado Toast",
    //            category: "Breakfast",
    //            ingredients: [
    //                "Bread",
    //                "Avocado",
    //                "Salt",
    //                "Black Pepper",
    //                "Lemon Juice"
    //            ],
    //            instructions: [
    //                "Toast the bread.",
    //                "Mash avocado with lemon juice.",
    //                "Spread avocado on toast.",
    //                "Season with salt and pepper."
    //            ],
    //            servings: 1,
    //            timeMinutes: 10,
    //            userId: "mockUser",
    //            //difficulty: Difficulty.easy
    //        )
    //    ]
    
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
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(firebaseVM.userFavCollections) { collection in
                            let isAlreadySaved = collection.recipeIds.contains(recipeId)
                            
                            Button {
                                if !isAlreadySaved {
                                    collectionSelected = collection
                                    showAlert = true
                                }
                            } label: {
                                CollectionRectangle(
                                    imageurl: collection.imageUrl,
                                    name: collection.name,
                                    recipeCount: collection.recipeIds.count,
                                    isAlreadySaved: isAlreadySaved
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isAlreadySaved)
                        }
                    }
                    .padding()
                }//srool vview
                
                NavigationLink {
                    CreateCollection()
                } label: {
                    Label("Create New Collection", systemImage: "plus.circle.fill")
                        .padding()
                        .font(.system(size: 20))
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .padding(.bottom)
            }
            .navigationTitle("Save to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                firebaseVM.fecthUsersCollections()
            }
            .alert(isPresented: $showAlert) {
                let selectedName = collectionSelected?.name ?? "Collection"
                return Alert(
                    title: Text("Save Recipe"),
                    message: Text("Save the recipe to \(selectedName)?"),
                    primaryButton: .default(Text("Save")) {
                        if let col = collectionSelected, let colId = col.id {
                            firebaseVM.saveToCollection(recipedId: recipeId, collectionId: colId)
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct CollectionRectangle: View {
    let imageurl: String
    let name: String
    let recipeCount: Int
    let isAlreadySaved: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(height: 100)
            .foregroundStyle(isAlreadySaved ? Color.gray.opacity(0.05) : Color.gray.opacity(0.1))
            .overlay {
                HStack(spacing: 15) {
                    AsyncImage(url: URL(string: imageurl)) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isAlreadySaved ? .gray : .primary)
                        
                        Text("\(recipeCount) RECIPES")
                            .foregroundStyle(.gray)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    if isAlreadySaved {
                        Text("Already saved there")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                            .padding(8)
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
    }
}

#Preview {
    SaveToCollectionView(recipeId: "52772")
}
