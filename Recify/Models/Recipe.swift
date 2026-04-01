//
//  Recipe.swift
//  Recify
//
//  Created by netblen on 2026-02-02.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Recipe: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var category: String
    var ingredients: [String]
    var instructions: String
    var imageURL : String?
    
    var servings: Int
    var userId: String
    var inPantry: Bool
    
    let prepTime: Int
    let calories: Int
    let level: String
    
    var searchTitle: String // New field for case-insensitive search
    
    init(title: String,
         category: String,
         ingredients: [String],
         instructions: String,
         imageURL: String?,
         servings: Int,
         userId: String,
         inPantry: Bool,
         prepTime: Int,
         calories: Int,
         level: String,
         searchTitle: String) {
        self.title = title
        self.category = category
        self.ingredients = ingredients
        self.instructions = instructions
        self.imageURL = imageURL
        self.servings = servings
        self.userId = userId
        self.inPantry = inPantry
        self.prepTime = prepTime
        self.calories = calories
        self.level = level
        self.searchTitle = searchTitle
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id ?? title)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        if let lid = lhs.id, let rid = rhs.id {
            return lid == rid
        }
        return lhs.title == rhs.title
    }
}

enum RecipeCategory: String, CaseIterable {
    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case drinks = "Drinks"
    case dessert = "Dessert"
}

enum RecipeDetailAttribute: String, CaseIterable {
    case prepTime = "PREP TIME"
    case calories = "CALORIES"
    case level = "LEVEL"
    
    func color(for value: String) -> Color {
        switch self {
        case .prepTime:
            return Color(red: 0.68, green: 0.85, blue: 0.90)
        case .calories:
            return Color(red: 1.0, green: 0.95, blue: 0.95)
        case .level:
            switch value.lowercased(){
            case "easy": return Color.green.opacity(0.2)
            case "medium": return Color.blue.opacity(0.2)
            case "hard": return Color.orange.opacity(0.2)
            default: return Color.gray.opacity(0.2)
            }
        }
    }
    
    //enum Difficulty: String, Codable, CaseIterable {
    //    case easy = "Easy"
    //    case medium = "Medium"
    //    case hard = "Hard"
    //    // idk if i should make a new enum for thsi as like levels or wtv
    //    //    case beginner = "Beginner"
    //    //    case intermidiate = "Intermidiate"
    //    //    case advanced = "Advanced"
    //}
    
}
