//
//  Recipe.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var category: String //whys this a strings? and not an enum 
    var ingredients: [String]
    var instructions: String
    //TODO: we need to add ijages to the firebaseif there aisnt nay why of saving them yeyt idk
    var imageUrl : String? //TODO: i chcnged this make sure i chcnge it every where

    var servings: Int
    var userId: String
    var inPantry: Bool
    
    let prepTime: Int
    let calories: Int
    let level: String
    
    init(id: String? = nil,
         title: String,
         category: String,
         ingredients: [String],
         instructions: String,
         imageUrl: String,
         servings: Int,
         userId: String,
         inPantry: Bool,
         prepTime: Int,
         calories: Int,
         level: String) {
        self.id = id
        self.title = title
        self.category = category
        self.ingredients = ingredients
        self.instructions = instructions
        self.imageUrl = imageUrl
        self.servings = servings
        self.userId = userId
        self.inPantry = inPantry
        self.prepTime = prepTime
        self.calories = calories
        self.level = level
    }
}

enum RecipeCategory: String, CaseIterable {
    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case drinks = "Drinks"
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
