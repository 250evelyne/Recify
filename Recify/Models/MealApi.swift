//
//  MealApi.swift
//  Recify
//
//  Created by netblen on 08-03-2026.
//

import Foundation

struct MealResponse: Codable {
    let meals: [MealApi]? 
}

struct MealApi: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    var id: String { idMeal }
}
