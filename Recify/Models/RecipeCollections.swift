//
//  RecipeCollections.swift
//  Recify
//
//  Created by Macbook on 2026-03-10.
//

import Foundation

struct RecipeCollection: Identifiable, Codable {
    var id: String?   // Firestore documentID
    var name: String
    var recipes: [Recipe]
}
