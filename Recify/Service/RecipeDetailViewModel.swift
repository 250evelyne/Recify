//
//  RecipeDetailViewModel.swift
//  Recify
//
//  Created by netblen on 08-03-2026.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe?
    @Published var isLoading: Bool = false
    @Published var ingredients: [RecipeIngredient] = []
    @Published var instructions: [String] = []
    
    
    func checkPantryStatus() {
        let userPantry = FirebaseViewModel.shared.ingredients.map { $0.name.lowercased() }
        
        for index in ingredients.indices {
            let rawName = ingredients[index].rawName.lowercased()
            ingredients[index].inPantry = userPantry.contains(where: {
                rawName.contains($0) || $0.contains(rawName)
            })
        }
    }
    
    func fetchRecipeDetails(idMeal: String) async {
        isLoading = true
        
        let isFirestoreID = idMeal.count > 10
        
        if isFirestoreID {
            do {
                //fetch the custom recipe straight from Firebase using the ID
                let document = try await Firestore.firestore().collection("recipes").document(idMeal).getDocument()
                if let customRecipe = try? document.data(as: Recipe.self) {
                    self.recipe = customRecipe
                    
                    self.ingredients = customRecipe.ingredients.map {
                        RecipeIngredient(name: $0, rawName: $0, inPantry: false)
                    }
                    
                    let cleanedSteps = customRecipe.instructions
                        .components(separatedBy: CharacterSet.newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .map { $0.replacingOccurrences(of: "^(?i)(step\\s*)?\\d+[:\\.-]?\\s*", with: "", options: .regularExpression) }
                        .filter { !$0.isEmpty }
                    
                    self.instructions = cleanedSteps.isEmpty ? [customRecipe.instructions] : cleanedSteps
                    
                    self.checkPantryStatus()
                    self.isLoading = false
                    return
                }
            } catch {
                print("Error fetching custom recipe from Firestore: \(error.localizedDescription)")
            }
        }
        
        // MARK: - API Fetch
        let urlString: String
        if idMeal.rangeOfCharacter(from: CharacterSet.letters) != nil {
            let encodedName = idMeal.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? idMeal
            urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encodedName)"
        } else {
            urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(idMeal)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]],
               let meal = meals.first {
                
                let thumbURL = meal["strMealThumb"] as? String ?? ""
                let mealTitle = meal["strMeal"] as? String ?? "Fetched Recipe"
                let mealCategory = meal["strCategory"] as? String ?? "General"
                
                if let instructionsString = meal["strInstructions"] as? String {
                    self.instructions = instructionsString
                        .components(separatedBy: CharacterSet.newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .map { $0.replacingOccurrences(of: "^(?i)(step\\s*)?\\d+[:\\.-]?\\s*", with: "", options: .regularExpression) }
                        .filter { !$0.isEmpty }
                }
                
                var fetchedIngredients: [RecipeIngredient] = []
                let userPantry = FirebaseViewModel.shared.ingredients.map { $0.name.lowercased() }
                
                var ingredientCount = 0
                for i in 1...20 {
                    if let ingredient = meal["strIngredient\(i)"] as? String,
                       let measure = meal["strMeasure\(i)"] as? String,
                       !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        
                        //check if this ingredient is in the user pantry
                        ingredientCount += 1
                        let inPantry = userPantry.contains(where: { ingredient.lowercased().contains($0) })
                        
                        fetchedIngredients.append(RecipeIngredient(
                            name: "\(measure) \(ingredient)",
                            rawName: ingredient,
                            inPantry: inPantry
                        ))
                    }
                }
                self.ingredients = fetchedIngredients
                
                self.checkPantryStatus()
                
                let meta = generateMetadata(
                    instructionCount: self.instructions.count,
                    ingredientCount: ingredientCount
                )
                
                //recipe object
                self.recipe = Recipe(
                    title: mealTitle,
                    category: mealCategory,
                    ingredients: fetchedIngredients.map { $0.rawName },
                    instructions: meal["strInstructions"] as? String ?? "",
                    imageURL: thumbURL,
                    servings: 4,
                    userId: "",
                    inPantry: false,
                    prepTime: meta.time,
                    calories: meta.kcal,
                    level: meta.level,
                    searchTitle: (meal["strMeal"] as? String ?? "Unknown Recipe").lowercased()
                )
            }
        } catch {
            print("Error fetching details: \(error)")
        }
        isLoading = false
    }
    
    private func generateMetadata(instructionCount: Int, ingredientCount: Int) -> (time: Int, kcal: Int, level: String) {
        //estimate
        let estimatedMinutes = 5 + (instructionCount * 3)
        //estimate
        let estimatedKcal = 150 + (ingredientCount * 45)
        
        var difficulty = "Easy"
        if instructionCount > 10 || ingredientCount > 12 {
            difficulty = "Hard"
        } else if instructionCount > 5 || ingredientCount > 7 {
            difficulty = "Medium"
        }
        
        return (estimatedMinutes, estimatedKcal, difficulty)
    }
    
    
    func checkShoppingListStatus(shoppingListItems: [Ingredients]) {
        for index in ingredients.indices {
            let rawName = ingredients[index].rawName.lowercased()
            
            let alreadyInCart = shoppingListItems.contains { cartItem in
                cartItem.name.lowercased() == rawName
            }
            
            ingredients[index].inCart = alreadyInCart
        }
    }
}

