//
//  Filters.swift
//  Recify
//
//  Created by Macbook on 2026-02-07.
//

import Foundation


enum Filters: String, CaseIterable, Identifiable, Codable{ //codable for the api
    
//    static var allFilters : [Filters] {
//        return [.all ,.vegetables, .fruits, .proteins, .dairy, .seasoning ,.grains ,.oils ,.sweetners ,.condiments]
//    }
    
    var id:Self {self}
    
    case all = "All"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case proteins = "Proteins"
    case dairy = "Dairy & Alternatives"
    case seasoning = "Seasonings, Herbs & Spices"
    case grains = "Starches & Grains"
    case oils = "Fats & Oils"
    case sweetners = "Sweeteners"
    case condiments = "Condiments & Sauces"
    case liquids = "Liquids"
    case other = "Other"
    
    
    var icon: String {
        switch self {
        case .liquids: return "drop.fill"
        case .all: return "square.grid.2x2.fill"
        case .vegetables: return "carrot.fill"
        case .fruits: return "applelogo"
        case .proteins: return "bolt.fill"
        case .dairy: return "takeoutbag.and.cup.and.straw.fill"
        case .seasoning: return "flame.fill"
        case .grains: return "bag.fill"
        case .oils: return "drop.fill"
        case .sweetners: return "cube.fill"
        case .condiments: return "waterbottle"
        case .other : return "circle.grid.2x2.fill" //idk if this is a good icon but i didnt find any more for now
        }
    }
    
    
    /// im thinking of add a color var for each icon 
}
