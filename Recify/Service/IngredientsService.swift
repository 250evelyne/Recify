//
//  IngredientsService.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
//

import Foundation

enum HttpMethod: String {
    case GET, POST, PUT, DELETE
}

class IngredientsService {
    private let webService = WebService()
    private let baseUrl = "https://www.themealdb.com/api/json/v1/1/list.php?i=list"
    
    private var cachedIngredients: [Ingredients] = []
    
    func fetchAllIngredients(forceRefresh: Bool = false) async -> [Ingredients] {
        if !forceRefresh && !cachedIngredients.isEmpty {
            return cachedIngredients
        }
        
        let result: IngredientResponse? = await webService.sendRequest(toUrl: baseUrl, method: .GET)
        let rawMeals = result?.meals ?? []
        
        self.cachedIngredients = []
        
        var uniqueNames = Set<String>()
        let uniqueRawMeals = rawMeals.filter { meal in
            guard !uniqueNames.contains(meal.strIngredient) else { return false }
            uniqueNames.insert(meal.strIngredient)
            return true
        }
        
        self.cachedIngredients = uniqueRawMeals.map { apiItem in
            Ingredients(
                apiId: apiItem.idIngredient,
                name: apiItem.strIngredient,
                quantity: 1,
                unit: .pcs,
                imageUrl: apiItem.image,
                category: self.autoAssignCategory(from: apiItem.strIngredient)
            )
        }
        
        return cachedIngredients
    }
    
    private func autoAssignCategory(from name: String) -> Filters {
        let lower = name.lowercased()
        
        if ["water", "stock", "broth", "juice", "wine"].contains(where: lower.contains) { return .liquids }
        if ["apple", "banana", "orange", "lemon", "lime", "berry", "strawberry", "grape"].contains(where: lower.contains) { return .fruits }
        if ["butter", "oil", "margarine", "lard"].contains(where: lower.contains) { return .oils }
        
        if lower.contains("beef") || lower.contains("chicken") || lower.contains("pork") || lower.contains("fish") {
            return .proteins
        } else if lower.contains("milk") || lower.contains("cheese") || lower.contains("yogurt") {
            return .dairy
        } else if lower.contains("rice") || lower.contains("pasta") || lower.contains("flour") {
            return .grains
        } else if ["salt", "pepper", "clove", "thyme", "oregano", "ginger"].contains(where: lower.contains) {
            return .seasoning
        }
        
        return .vegetables
    }
    
    func getIngredients(page: Int, pageSize: Int = 20) async -> [Ingredients] {
        let all = await fetchAllIngredients()
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, all.count)
        
        guard startIndex < all.count else { return [] }
        return Array(all[startIndex..<endIndex])
    }
}

//    let id: Int?
//    let name: String
//    var quantity : Int?
//    var unit : units?
//    let imageUrl: String
//    let category: Filters?
    
    
    /* wrong i dont need this
    func createIngredient(name: String, imageUrl: String, category: Filters) async -> Ingredients? {
        
        let newIngredient = Ingredients(id: nil, name: name, imageUrl: imageUrl, category: category)
        
        
        let created : Ingredients? = await webService.sendRequest(toUrl: baseUrl, method: .POST, body: newIngredient)
        
        return created
    }*/
    
    
    /* wrong i dont need this
    func updateIngredient(_ ingredient: Ingredients) async -> Ingredients? {
        
        guard let id = ingredient.id else{
            print("Missing id for update")
            return nil
        }
        
        let url = "\(baseUrl)/\(id)"
        
        let updated : Ingredients? = await webService.sendRequest(toUrl: url, method: .PUT, body: ingredient)
        
        return updated
    }*/
    
    
    

