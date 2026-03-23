//
//  DietaryRestrictions.swift
//  Recify
//
//  Created by Macbook on 2026-03-03.
//

import Foundation

enum DietaryRestriction: String, CaseIterable, Codable, Hashable {
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case nutFree = "Nut-Free"
    case keto = "Keto"
    
    func matches(category: String, ingredients: [String]) -> Bool {
        let lowerCat = category.lowercased()
        let lowerIngs = ingredients.map { $0.lowercased() }
        
        switch self {
        case .vegan:
            return lowerCat == "vegan"
        case .vegetarian:
            return lowerCat == "vegetarian" || lowerCat == "vegan"
        case .glutenFree:
            return !lowerIngs.contains { $0.contains("flour") || $0.contains("wheat") }
        case .dairyFree:
            return !lowerIngs.contains { $0.contains("milk") || $0.contains("cheese") || $0.contains("butter") }
        default:
            return true
        }
    }
}
