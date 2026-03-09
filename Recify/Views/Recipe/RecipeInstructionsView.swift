//
//  CalendarView.swift
//  Recify
//
//  Created by mac on 2026-03-07.
//

import SwiftUI  //TODO: add the calendar button that envlyne did was working but idk what happend (sheet)

struct RecipeInstructionsView: View {
    let mealId: String
    let recipeTitle: String
    let recipeImage: String
    let rating: Double = 4.8
    let reviewCount: String = "1.2k"
    let prepTime: String = "25 min"
    let calories: String = "450 kcal"
    let difficulty: String = "Medium"
    let isEditorChoice: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State private var showCalendar = false
    @StateObject private var viewModel = RecipeDetailViewModel()
    @StateObject private var ingredientViewModel = IngredientViewModel()
    @State private var showAddedAlert = false
    
    var pantryCount: Int {
        viewModel.ingredients.filter { $0.inPantry }.count
    }
    
    var isFavorite: Bool {
        FirebaseViewModel.shared.isRecipeSaved(mealId: mealId)
    }
    
    // MARK: - Helper Functions
    private func addMissingIngredientsToCart() {
        let missingItems = viewModel.ingredients.filter { !$0.inPantry }
        
        Task {
            for item in missingItems {
                // This uses the Search API logic to match categories automatically
                let detectedCategory = await ingredientViewModel.fetchCategoryFor(ingredientName: item.rawName)
                
                FirebaseViewModel.shared.addToShoppingList(
                    name: item.rawName,
                    imageUrl: "",
                    category: detectedCategory,
                    quantity: 1,
                    unit: .pcs,
                    recipeName: recipeTitle
                )
            }
            await MainActor.run {
                showAddedAlert = true
            }
        }
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack {
                    Spacer().frame(height: 200)
                    ProgressView("Loading Recipe Details...")
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    // Recipe Img
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: recipeImage)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(height: 280)
                        .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text(recipeTitle)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Rating section...
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                            Text("\(String(format: "%.1f", rating)) (\(reviewCount) reviews)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Info Cards...
                        HStack(spacing: 12) {
                            InfoCard(title: "PREP TIME", value: prepTime, color: Color(red: 0.68, green: 0.85, blue: 0.90))
                            InfoCard(title: "CALORIES", value: calories, color: Color(red: 1.0, green: 0.95, blue: 0.95))
                            InfoCard(title: "LEVEL", value: difficulty, color: Color(red: 0.88, green: 0.98, blue: 0.88))
                        }
                        
                        // Ingredients Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Ingredients")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                
                                if pantryCount < viewModel.ingredients.count {//TODO: make it so that it cant be lcikced twice
                                    Button(action: addMissingIngredientsToCart) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "cart.badge.plus")
                                            Text("Add Missing")
                                        }
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.pink.opacity(0.1))
                                        .foregroundColor(.pink)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            
                            ForEach(viewModel.ingredients) { ingredient in
                                IngredientRow(name: ingredient.name, inPantry: ingredient.inPantry)
                            }
                        }
                        
                        // Instructions Section...
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
                                InstructionStep(number: index + 1, text: instruction, color: index % 2 == 0 ? .blue : .pink)
                            }
                        }
                        
                        // Start cooking btn
                        NavigationLink(destination: CookingModeTabView(recipeTitle: recipeTitle, steps: viewModel.instructions)) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Start Cooking")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await viewModel.fetchRecipeDetails(idMeal: mealId)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    FirebaseViewModel.shared.toggleFavorite(mealId: mealId, title: recipeTitle, imageURL: recipeImage)
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.pink)
                }
            }
        }
        .alert("Added to Cart!", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All missing ingredients were successfully added to your Shopping List.")
        }
    }
}


struct RecipeIngredient: Identifiable {
    let id = UUID()
    let name: String
    let rawName: String
    let inPantry: Bool
}


//supporting views

struct InfoCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(12)
    }
}

struct IngredientRow: View {
    let name: String
    let inPantry: Bool
    
    var body: some View {
        HStack {
            Image(systemName: inPantry ? "checkmark.circle.fill" : "plus.circle.fill")
                .foregroundColor(inPantry ? .green : .pink)
                .font(.title3)
            
            Text(name)
                .font(.body)
            
            Spacer()
            
            Text(inPantry ? "IN PANTRY" : "TO BUY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(inPantry ? .green : .pink)
        }
        .padding()
        .background(inPantry ? Color.green.opacity(0.1) : Color.pink.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

///sample data

//struct RecipeInstructionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeInstructionsView(
//            recipeTitle: "Creamy Avocado Pasta",
//            recipeImage: "pasta-sample",
//            rating: 4.8,
//            reviewCount: "1.2k",
//            prepTime: "15 min",
//            calories: "450 kcal",
//            difficulty: "Easy",
//            ingredients: [
//                RecipeIngredient(name: "Ripe Avocados (2)", inPantry: true),
//                RecipeIngredient(name: "Garlic (3 cloves)", inPantry: true),
//                RecipeIngredient(name: "Whole Grain Pasta (500g)", inPantry: false),
//                RecipeIngredient(name: "Olive Oil (2 tbsp)", inPantry: true),
//                RecipeIngredient(name: "Salt (1 tsp)", inPantry: true),
//                RecipeIngredient(name: "Black Pepper (1/2 tsp)", inPantry: true),
//                RecipeIngredient(name: "Lemon Juice (1 tbsp)", inPantry: false),
//                RecipeIngredient(name: "Fresh Basil (optional)", inPantry: false),
//                RecipeIngredient(name: "Parmesan Cheese (50g)", inPantry: false)
//            ],
//            instructions: [
//                "Bring a large pot of salted water to a boil. Cook the pasta according to package instructions until al dente.",
//                "While pasta cooks, blend the avocados, garlic, and olive oil in a food processor until smooth and creamy.",
//                "Drain pasta and toss with avocado sauce. Season with salt and pepper to taste. Serve immediately."
//            ],
//            isEditorChoice: true
//        )
//    }
//}

struct RecipeInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeInstructionsView(
            mealId: "52772", 
            recipeTitle: "Teriyaki Chicken Casserole",
            recipeImage: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg"
        )
    }
}
