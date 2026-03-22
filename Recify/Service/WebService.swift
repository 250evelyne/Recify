//
//  WebService.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case faildToDecodeResponse
}

//enum HttpMethod: String {
//    case get = "GET"
//    case post = "POST"
//}
//
//struct MealResponse: Codable {
//    let meals: [MealApi]?
//}

class WebService {
    
    
    func sendRequest<T: Codable>(toUrl: String, method: HttpMethod, body: T? = nil) async -> T? {
//        do{
//            guard let url = URL(string: toUrl)
//            else {
//                throw NetworkError.badUrl
//            }

        do {
            guard let url = URL(string: toUrl) else { throw NetworkError.badUrl }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = method.rawValue
            
            if let body = body {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            guard 200..<300 ~= response.statusCode else { throw NetworkError.badStatus }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Request Failed: ", error.localizedDescription)
            return nil
        }
        
    }
    

    func fetchFilteredRecipes(query: String, filters: SearchFilters) async -> [Recipe] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encodedQuery)"
        
        print("API Request: \(urlString)")
        
        let response: MealResponse? = await sendRequest(toUrl: urlString, method: .get, body: nil as MealResponse?)
        
        guard let fetchedMeals = response?.meals else {
            print("❌ API: No meals found for '\(query)'")
            return []
        }
        
        // Convert API meals to our Recipe model
        let allRecipes = fetchedMeals.map { mapMealToRecipe(meal: $0) }
        print("✅ API: Found \(allRecipes.count) recipes. Now applying time/diet filters...")
        
        return allRecipes.filter { recipe in
            // --- 1. Filter by Cook Time ---
            let matchesTime: Bool
            if let selectedTime = filters.cookTime {
                switch selectedTime {
                case .under15: matchesTime = recipe.prepTime <= 15
                case .between15And30: matchesTime = recipe.prepTime > 15 && recipe.prepTime <= 30
                case .over30: matchesTime = recipe.prepTime > 30
                }
            } else {
                matchesTime = true // If no time selected, everything is a match
            }
            
            // --- 2. Filter by Dietary Restrictions ---
            let matchesDiet: Bool
            if filters.dietaryRestrictions.isEmpty {
                matchesDiet = true
            } else {
                // Check if any of the selected restrictions match the recipe category
                matchesDiet = filters.dietaryRestrictions.contains { restriction in
                    recipe.category.lowercased().contains(restriction.rawValue.lowercased())
                }
            }
            
            if !matchesTime || !matchesDiet {
                print("Filtering out '\(recipe.title)' (Time Match: \(matchesTime), Diet Match: \(matchesDiet))")
            }
            
            return matchesTime && matchesDiet
        }
    }
    
    func mapMealToRecipe(meal: MealApi) -> Recipe {
        let instructionText = meal.strInstructions ?? ""
        let instructionLength = instructionText.count
        
        let calculatedLevel: String
        let calculatedTime: Int
        
        //kinda logic if im not mistaking
        //Short instructions = Quick, Long instructions = Slow
        if instructionLength < 400 {
            calculatedLevel = "Easy"
            calculatedTime = 12 // Change to 12 so it falls into "Under 15"
        } else if instructionLength < 800 {
            calculatedLevel = "Medium"
            calculatedTime = 25 // Change to 25 so it falls into "15-30"
        } else {
            calculatedLevel = "Hard"
            calculatedTime = 45 // Change to 45 so it falls into "Over 30"
        }
        
        return Recipe(
            id: meal.idMeal,
            title: meal.strMeal ?? "Unknown Recipe",
            category: meal.strCategory ?? "General",
            ingredients: meal.allIngredients,
            instructions: meal.strInstructions ?? "No instructions provided.",
            imageURL: meal.strMealThumb ?? "",
            servings: 4,
            userId: "guest",
            inPantry: false,
            prepTime: calculatedTime,
            calories: 350,
            level: calculatedLevel
        )
    }
    
}
