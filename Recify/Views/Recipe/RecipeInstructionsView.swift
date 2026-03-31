//
//  CalendarView.swift
//  Recify
//
//  Created by mac on 2026-03-07.
//

import SwiftUI

struct RecipeInstructionsView: View {
    // MARK: - Properties
    let mealId: String
    let recipeTitle: String
    let recipeImage: String
    let prepTime: Int
    let difficulty: String
    
    var recipe: Recipe? = nil
    
    // Static display constants
    //    let rating: Double = 4.8
    //    let reviewCount: String = "1.2k"
    
    @Environment(\.dismiss) var dismiss
    //@State private var showCalendar = false
    @StateObject private var viewModel = RecipeDetailViewModel()
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @StateObject private var ingredientViewModel = IngredientViewModel()
    
    @State private var isShowingSheet = false
    @State private var showCalendar = false
    //@State private var isFavorite = false
    @State private var isAdded = false
    //     @ObservedObject private var firebaseVM = FirebaseViewModel.shared //idk looks like anabella has it above
    
    @State private var showAddedAlert = false
    
    private var isFavorite: Bool {
        firebaseVM.isRecipeSaved(mealId: mealId)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                recipeHeaderImage
                
                VStack(alignment: .leading, spacing: 20) {
                    recipeTitleSection
                    infoCardsSection
                    actionButtonsSection
                    ingredientsSection
                    instructionsSection
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            SaveToCollectionView(recipeId: mealId)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCalendar) {
            CalendarView()
        }
        .alert("Added to Cart", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Missing ingredients have been added to your shopping list.")
        }
        .onAppear {
            Task {
                if let customRecipe = recipe, !customRecipe.ingredients.isEmpty {
                    viewModel.ingredients = customRecipe.ingredients.map {
                        RecipeIngredient(name: $0, rawName: $0, inPantry: false)
                    }
                    
                    let cleanedSteps = customRecipe.instructions
                        .components(separatedBy: CharacterSet.newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .map { $0.replacingOccurrences(of: "^(?i)(step\\s*)?\\d+[:\\.-]?\\s*", with: "", options: .regularExpression) }
                        .filter { !$0.isEmpty }
                    
                    viewModel.instructions = cleanedSteps.isEmpty ? [customRecipe.instructions] : cleanedSteps
                    
                } else {
                    await viewModel.fetchRecipeDetails(idMeal: mealId)
                }
                
                viewModel.checkPantryStatus()
                viewModel.checkShoppingListStatus(shoppingListItems: firebaseVM.shoppingItems)
            }
        }
    }
    // MARK: - Sub-views
    private var recipeHeaderImage: some View {
        AsyncImage(url: URL(string: recipeImage)) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.2)
        }
        .frame(height: 280)
        .clipped()
    }
    
    private var recipeTitleSection: some View {
        Text(recipeTitle)
            .font(.title)
            .fontWeight(.bold)
    }
    
    private var infoCardsSection: some View {
        HStack(spacing: 12) {
            InfoCard(type: .prepTime, value: "\(prepTime) min")
            
            if let customRecipe = recipe {
                InfoCard(type: .calories, value: "\(customRecipe.calories) kcal")
            } else if let fetchedRecipe = viewModel.recipe {
                InfoCard(type: .calories, value: "\(fetchedRecipe.calories) kcal")
            } else {
                InfoCard(type: .calories, value: "-- kcal")
            }
            
            InfoCard(type: .level, value: difficulty)
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients (\(viewModel.ingredients.count))")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                // Use the computed property to show/hide button
                if !isAllAccountedFor {
                    addMissingButton
                }
            }
            
            VStack(spacing: 10) {
                ForEach(viewModel.ingredients) { ingredient in
                    IngredientRow(name: ingredient.name, inPantry: ingredient.inPantry)
                }
            }
        }
    }
    
    private var addMissingButton: some View {
        Button {
            addMissingIngredientsToCart()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isAdded ? "checkmark.circle" : "cart.badge.plus")
                Text(isAdded ? "Added" : "Add Missing")
            }
            .font(.caption).fontWeight(.bold)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(isAdded ? Color.gray.opacity(0.2) : Color.pink.opacity(0.1))
            .foregroundColor(isAdded ? .gray : .pink)
            .cornerRadius(20)
        }
        .disabled(isAdded)
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
                InstructionStep(number: index + 1, text: instruction, color: index % 2 == 0 ? .blue : .pink)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
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
            
            Button(action: { showCalendar = true }) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Add to Planner")
                        .fontWeight(.semibold)
                    //     var isFavorite: Bool { //me i think above is anabells new ui tho
                    //         firebaseVM.isRecipeSaved(mealId: mealId)
                    //     }
                    
                    //     var body: some View {
                    
                    
                    //         ScrollView {
                    //             if viewModel.isLoading {
                    //                 loadingState
                    //             } else {
                    //                 VStack(spacing: 0) {
                    //                     recipeHeaderImage
                    
                    //                     VStack(alignment: .leading, spacing: 20) {
                    //                         recipeTitleSection
                    //                         infoCardsSection
                    //                         ingredientsSection
                    //                         instructionsSection
                    //                         actionButtonsSection
                    //                     }
                    //                     .padding()
                    //                 }
                    //             }
                    //         }
                    //         .navigationTitle(recipeTitle)
                    //         .navigationBarTitleDisplayMode(.inline)
                    //         .toolbar {
                    //             ToolbarItem(placement: .navigationBarTrailing) {
                    // //<<<<<<< HEAD
                    //                 Button(action: {
                    //                     FirebaseViewModel.shared.toggleFavorite(mealId: mealId, title: recipeTitle, imageURL: recipeImage)
                    //                     isShowingSheet = true
                    //                 }) {
                    //                     Image(systemName: isFavorite ? "heart.fill" : "heart")
                    //                         .foregroundColor(.pink)
                }
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
        
    private var favoriteButton: some View {
        Button(action: {
            if !isFavorite {
                firebaseVM.toggleFavorite(mealId: mealId, title: recipeTitle, imageURL: recipeImage)
            }
            
            //thiw always show the sheet so the user can manage collections
            isShowingSheet = true
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(.pink)
                .font(.title3)
        }
    }
    
    // MARK: - Helper Logic
    private var isAllAccountedFor: Bool {
        //checks if every ingredient is either in the pantry or already in the cart
        viewModel.ingredients.allSatisfy { $0.inPantry || $0.inCart }
    }
    
    private func addMissingIngredientsToCart() {
        let missingItems = viewModel.ingredients.filter { !$0.inPantry }
        
        Task {
            for item in missingItems {
                let alreadyInCart = firebaseVM.shoppingItems.contains {
                    $0.name.lowercased() == item.rawName.lowercased()
                }
                
                if !alreadyInCart {
                    let detectedCategory = await ingredientViewModel.fetchCategoryFor(ingredientName: item.rawName)
                    firebaseVM.addToShoppingList(
                        name: item.rawName,
                        imageUrl: "",
                        category: detectedCategory,
                        quantity: 1,
                        unit: .pcs,
                        recipeName: recipeTitle
                    )
                }
            }
            
            await MainActor.run {
                showAddedAlert = true
                isAdded = true
            }
        
            //         .sheet(isPresented: $showCalendar) {
            // //=======
            //             }
            // //        }
            // //        .onAppear {
            // //            Task {
            // //                await viewModel.fetchRecipeDetails(idMeal: mealId)
            // //                viewModel.checkPantryStatus()
            // //                viewModel.checkShoppingListStatus(shoppingListItems: firebaseVM.shoppingItems)
            // //            }
            // //        }        .sheet(isPresented: $showCalendar) {
            // //>>>>>>> origin/Anabella
            // //            CalendarView()
            // //        }
            //         .alert("Added to Cart!", isPresented: $showAddedAlert) {
            //             Button("OK", role: .cancel) { }
            //         } message: {
            //             Text("All missing ingredients were successfully added to your Shopping List.")
        }
    }
    
    // MARK: - Sub-views (Optimized breaking up of expressions)
    
    private var loadingState: some View {
        VStack {
            Spacer().frame(height: 200)
            ProgressView("Loading Recipe Details...")
            Spacer()
        }
    }
    
    //    private var recipeHeaderImage: some View {
    //        AsyncImage(url: URL(string: recipeImage)) { image in
    //            image.resizable().aspectRatio(contentMode: .fill)
    //        } placeholder: {
    //            Color.gray.opacity(0.2)
    //        }
    //        .frame(height: 280)
    //        .clipped()
    //    }
    
    //    private var recipeTitleSection: some View {
    //        VStack(alignment: .leading, spacing: 8) {
    //            Text(recipeTitle)
    //                .font(.title)
    //                .fontWeight(.bold)
    
    //            HStack(spacing: 4) {
    //                ForEach(0..<5) { index in
    //                    Image(systemName: index < Int(rating) ? "star.fill" : "star")
    //                        .foregroundColor(.yellow)
    //                        .font(.caption)
    //                }
    //                Text("\(String(format: "%.1f", rating)) (\(reviewCount) reviews)")
    //                    .font(.subheadline)
    //                    .foregroundColor(.gray)
    //            }
//}
//
//}

    
    
//    private var isAllAccountedFor: Bool {
//        return viewModel.ingredients.allSatisfy { $0.inPantry || $0.inCart }
//    }
//    
//    private var infoCardsSection: some View {
//        HStack(spacing: 12) {
//            InfoCard(type: .prepTime, value: "\(prepTime) min")
//            
//            if let recipe = viewModel.recipe {
//                InfoCard(type: .calories, value: "\(recipe.calories) kcal")
//            } else {
//                InfoCard(type: .calories, value: "350 kcal") // Default estimate
//            }
//            
//            InfoCard(type: .level, value: difficulty)
//        }
//    }
//    
//    private var ingredientsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text("Ingredients (\(viewModel.ingredients.count))")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                Spacer()
//                
//              
//                if !isAllAccountedFor {
//                    addMissingButton
//                }
//            }
//            
//            VStack {
//                ForEach(viewModel.ingredients) { ingredient in
//                    IngredientRow(name: ingredient.name, inPantry: ingredient.inPantry)
//                }
//            }
//        }
//    }
//    
//    private var addMissingButton: some View {
//        Button {
//            addMissingIngredientsToCart()
//        } label: {
//            HStack(spacing: 4) {
//                Image(systemName: isAdded ? "checkmark.circle" : "cart.badge.plus")
//                Text(isAdded ? "Added" : "Add Missing")
//            }
//            .font(.caption).fontWeight(.bold)
//            .padding(.horizontal, 10).padding(.vertical, 6)
//            .background(isAdded ? Color.gray.opacity(0.2) : Color.pink.opacity(0.1))
//            .foregroundColor(isAdded ? .gray : .pink)
//            .cornerRadius(20)
//        }
//        .disabled(isAdded)
//    }
//    
//    private var instructionsSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Instructions")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            ForEach(Array(viewModel.instructions.enumerated()), id: \.offset) { index, instruction in
//                InstructionStep(number: index + 1, text: instruction, color: index % 2 == 0 ? .blue : .pink)
//            }
//        }
//    }
//    
//    private var actionButtonsSection: some View {
//        VStack(spacing: 12) {
//            NavigationLink(destination: CookingModeTabView(recipeTitle: recipeTitle, steps: viewModel.instructions)) {
//                HStack {
//                    Image(systemName: "flame.fill")
//                    Text("Start Cooking")
//                        .fontWeight(.semibold)
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.pink)
//                .cornerRadius(12)
//            }
//            
//            Button(action: { showCalendar = true }) {
//                HStack {
//                    Image(systemName: "calendar")
//                    Text("Add to Planner")
//                        .fontWeight(.semibold)
//                }
//                .foregroundColor(.green)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.green.opacity(0.1))
//                .cornerRadius(12)
//            }
//        }
//    }
//    
//    private var favoriteButton: some View {
//        Button(action: {
//            firebaseVM.toggleFavorite(mealId: mealId, title: recipeTitle, imageURL: recipeImage)
//        }) {
//            Image(systemName: isFavorite ? "heart.fill" : "heart")
//                .foregroundColor(.pink)
//        }
//    }
//    
//    // MARK: - Helper Logic
//    private func addMissingIngredientsToCart() {
//        let missingItems = viewModel.ingredients.filter { !$0.inPantry }
//        
//        Task {
//            for item in missingItems {
//                // Check again inside the loop to prevent double-adding
//                let alreadyInCart = firebaseVM.shoppingItems.contains {
//                    $0.name.lowercased() == item.rawName.lowercased()
//                }
//                
//                if !alreadyInCart {
//                    let detectedCategory = await ingredientViewModel.fetchCategoryFor(ingredientName: item.rawName)
//                    FirebaseViewModel.shared.addToShoppingList(
//                        name: item.rawName,
//                        imageUrl: "",
//                        category: detectedCategory,
//                        quantity: 1,
//                        unit: .pcs,
//                        recipeName: recipeTitle
//                    )
//                }
//            }
//            
//            await MainActor.run {
//                showAddedAlert = true
//                isAdded = true
//            }
//        }
//    }
    
    
}

// MARK: - Supporting Structs

struct RecipeIngredient: Identifiable {
    let id = UUID()
    let name: String
    let rawName: String
    //let inPantry: Bool
    var inPantry: Bool
    var inCart: Bool = false
}


//supporting views

struct InfoCard: View {
    //let title: String
    let type: RecipeDetailAttribute
    let value: String
    //let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(type.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            // Using your enum logic here:
                .background(type.color(for: value))
                .cornerRadius(12)
        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(color)
//        .cornerRadius(12)
    }
}

struct IngredientRow: View {
    let name: String
    let inPantry: Bool
    
    var body: some View {
        HStack {
            Image(systemName: inPantry ? "checkmark.circle.fill" : "plus.circle.fill")
                .foregroundColor(inPantry ? Color("myGreen") : .pink)
                .font(.title3)
            
            Text(name)
                .font(.body)
            
            Spacer()
            
            Text(inPantry ? "IN PANTRY" : "TO BUY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(inPantry ? Color("myGreen") : .pink)
        }
        .padding()
        .background(inPantry ? Color("myGreen").opacity(0.1) : Color.pink.opacity(0.1))
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

// MARK: - Preview
struct RecipeInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeInstructionsView(
            mealId: "52772",
            recipeTitle: "Teriyaki Chicken Casserole",
            recipeImage: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            prepTime: 12,
            difficulty: "Easy"
        )
        .environmentObject(FirebaseViewModel.shared)
    }
}
