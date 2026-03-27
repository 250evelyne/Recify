//
//  SaveToCollectionView.swift
//  Recify
//
//  Created by Macbook on 2026-03-21.
//

import SwiftUI

struct SaveToCollectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var collectionSelected : String? = nil
    
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
    
    var recipeId : String
    
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(FirebaseViewModel.shared.userFavCollections) { collection in
                            
                            CollectionRectangle(
                                imageurl: collection.imageUrl,
                                name: collection.name,
                                recipeCount: collection.recipeIds.count,
                                isSelected: collectionSelected == collection.id
                            )
                            .onTapGesture {
                                collectionSelected = collection.id
                                showAlert = true
                            }
                            
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
                }.buttonStyle(.borderedProminent)
                
            }
            .alert(isPresented: $showAlert) {
                let collectionName = FirebaseViewModel.shared.userFavCollections.first(where: {
                    $0.id == collectionSelected
                })?.name ?? "Collection" //TODO: get the actually collection name not just the first one
                
                return Alert(
                    title: Text("Save Recipe"),
                    message: Text("Save the recipe to \(collectionName)?"),
                    primaryButton: .default(Text("Save")) {
                        confirmAndSave()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle("Save to Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                FirebaseViewModel.shared.fecthUsersCollections()
            }
        }//nav
    }
    
    
    private func confirmAndSave() {
        // Check if we actually have a collection selected
        if let collectionID = collectionSelected {
            // Here we pass the specific IDs to your ViewModel
            FirebaseViewModel.shared.saveToCollection(
                recipedId: recipeId, //TODO: see if its saveing the rigth id
                collectionId: collectionID
            )
            dismiss() //TODO: chekc if the dismiss sdismiss the whole sheet
        }
    }
}

struct CollectionRectangle: View {
    let imageurl: String
    let name: String
    let recipeCount: Int
    let isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(height: 120)
            .foregroundStyle(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
            .overlay {
                HStack(spacing: 15) {
                    AsyncImage(url: URL(string: imageurl)) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 70, height: 70)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.system(size: 20, weight: .bold))
                        Text("\(recipeCount) RECIPES")
                            .foregroundStyle(.gray)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    
                    Spacer()
  
                }
                .padding(.horizontal)
            }
    }
}


#Preview {
    SaveToCollectionView(recipeId: "1")
}
