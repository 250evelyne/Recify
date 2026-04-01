//
//  IngredientApi.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
//

import Foundation

struct IngredientResponse: Codable {
    let meals: [IngredientApi]
}

struct IngredientApi: Codable, Identifiable { // Add Identifiable
    let idIngredient: String
    let strIngredient: String
    
    // Add this to satisfy Identifiable using the API's unique ID
    var id: String { idIngredient }
    
    var image: String {
        "https://www.themealdb.com/images/ingredients/\(strIngredient).png"
    }
}
