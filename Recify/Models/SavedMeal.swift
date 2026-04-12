//
//  SavedMeal.swift
//  Recify
//
//  Created by mac on 2026-04-11.
//

import Foundation

struct SavedMeal: Identifiable, Codable {
    let id: UUID
    let recipeId: String
    let recipeName: String
    let recipeImage: String?
    let date: Date
    let mealType: String // "Breakfast", "Lunch", "Dinner"
    let prepTime: Int
    let difficulty: String
    
    init(id: UUID = UUID(), recipeId: String, recipeName: String, recipeImage: String?, date: Date, mealType: String, prepTime: Int, difficulty: String) {
        self.id = id
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.recipeImage = recipeImage
        self.date = date
        self.mealType = mealType
        self.prepTime = prepTime
        self.difficulty = difficulty
    }
}
