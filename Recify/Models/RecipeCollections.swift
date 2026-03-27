//
//  RecipeCollections.swift
//  Recify
//
//  Created by Macbook on 2026-03-10.
//

import Foundation
import FirebaseFirestore

struct RecipeCollection: Identifiable, Codable {
//    let id = UUID()   // Firestore documentID
    @DocumentID var id : String?
    var name: String
    var imageUrl: String
//    var recipes: [Recipe]
    var userId: String 
    var recipeIds: [String]
}
