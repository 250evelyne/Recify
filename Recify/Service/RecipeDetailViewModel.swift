//
//  RecipeDetailViewModel.swift
//  Recify
//
//  Created by netblen on 08-03-2026.
//

import SwiftUI

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var ingredients: [RecipeIngredient] = []
    @Published var instructions: [String] = []
    @Published var isLoading = true
    
    func fetchRecipeDetails(idMeal: String) async {
        isLoading = true
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(idMeal)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]],
               let meal = meals.first {
                
                // 1. Parse instructions and split them into an array of steps
                if let instructionsString = meal["strInstructions"] as? String {
                    self.instructions = instructionsString
                        .components(separatedBy: CharacterSet.newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    // NEW: This Regex removes "Step X:", "STEP X.", or "step X " from the start of the string
                        .map { $0.replacingOccurrences(of: "^(?i)step\\s*\\d+[:\\.-]?\\s*", with: "", options: .regularExpression) }
                        .filter { !$0.isEmpty }
                }
                
                
                var fetchedIngredients: [RecipeIngredient] = []
                let userPantry = FirebaseViewModel.shared.ingredients.map { $0.name.lowercased() }
                
                for i in 1...20 {
                    if let ingredient = meal["strIngredient\(i)"] as? String,
                       let measure = meal["strMeasure\(i)"] as? String,
                       !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        
                        //check if this ingredient is in the user pantry
                        let inPantry = userPantry.contains(where: { ingredient.lowercased().contains($0) })
                        
                        fetchedIngredients.append(RecipeIngredient(
                            name: "\(measure) \(ingredient)",
                            rawName: ingredient,
                            inPantry: inPantry
                        ))
                    }
                }
                self.ingredients = fetchedIngredients
            }
        } catch {
            print("Error fetching details: \(error)")
        }
        isLoading = false
    }
}
