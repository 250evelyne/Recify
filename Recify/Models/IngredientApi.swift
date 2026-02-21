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

struct IngredientApi: Codable {
    let idIngredient: String
    let strIngredient: String
    
    // The API doesn't provide a direct image URL in the list,
    // but you can construct it using the name.
    var image: String {
        "https://www.themealdb.com/images/ingredients/\(strIngredient).png"
    }
}
