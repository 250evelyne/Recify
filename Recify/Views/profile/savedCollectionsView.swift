//
//  savedCollectionsView.swift
//  Recify
//
//  Created by Macbook on 2026-03-10.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct savedCollectionsView: View {
    @StateObject var firebaseManager = FirebaseViewModel.shared
    @State var collections: [RecipeCollection] = []
    
    let mockRecipes: [Recipe] = [
        Recipe(
            id: "1",
            title: "Spaghetti Carbonara",
            category: "Dinner",
            ingredients: ["Pasta", "Eggs", "Cheese"],
            instructions: "Boil water, cook pasta, and mix with eggs and cheese.", // Changed to String
            imageURL: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
            servings: 2,
            userId: "123",
            inPantry: false,
            prepTime: 20,
            calories: 600,
            level: "Easy"
        )
    ]
    
    var mockCollections: [RecipeCollection] {
        [
            RecipeCollection(
                name: "Weeknight Dinners",
                recipes: mockRecipes
            )
        ]
    }
    
    
    var body: some View {
        ScrollView {
            
            let displayList = collections.isEmpty ? mockCollections : collections
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(displayList) { collection in
                    VStack {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.pink.opacity(0.7))
                            .padding(.bottom, 4)
                        
                        Text(collection.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Text("\(collection.recipes.count) Recipes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Saved Collections")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            fetchCollections()
        }
    }
    
    func fetchCollections() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("collections")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching: \(error.localizedDescription)")
                    return
                }
                
                self.collections = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: RecipeCollection.self)
                } ?? []
            }
    }
}

#Preview {
    NavigationView {
        savedCollectionsView()
    }
}
//struct savedCollectionsView: View {
//    @StateObject var firebaseManager = FirebaseViewModel.shared
//    let mockRecipes: [Recipe] = [
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
//    
//    var mockCollections: [RecipeCollection] {
//        [
//            RecipeCollection(
//                name: "Weeknight Dinners",
//                recipes: [mockRecipes[0]]
//            )
//        ]
//    }
//    
//    var body: some View {
//        ScrollView {
//            //Empty State
////            if firebaseManager.savedRecipes.isEmpty {
////                VStack(spacing: 16) {
////                    Image(systemName: "heart.slash")
////                        .font(.system(size: 60))
////                        .foregroundColor(.gray.opacity(0.4))
////
////                    Text("No Favorites Yet")
////                        .font(.title2)
////                        .fontWeight(.bold)
////
////                    Text("Tap the heart icon on any recipe to save it here for later!")
////                        .font(.subheadline)
////                        .foregroundColor(.gray)
////                        .multilineTextAlignment(.center)
////                        .padding(.horizontal, 40)
////                }
////                .frame(maxWidth: .infinity, alignment: .center)
////                .padding(.top, 100)
//                
//            //} else {
//                // MARK: - Saved Recipes Grid
//                LazyVGrid(
//                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
//                    spacing: 16
//                ) {
//                    //ForEach(firebaseManager.savedRecipes) { recipe in
//                    ForEach(mockCollections) { collection in
//                        
//                    }
//                }
//                .padding()
//            //}
//        }
//        .background(Color(.systemGroupedBackground))
//        .navigationTitle("Saved Collections")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            //ensures the page always grabs the latest favorites
//            firebaseManager.fetchSavedRecipes()
//            //TODO: anablla change to fecth saved collections
//        }
//    }
//
//}


