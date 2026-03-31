//
//  RecipeCollections.swift
//  Recify
//
//  Created by Macbook on 2026-03-10.
//

import Foundation
import FirebaseFirestore

struct RecipeCollection: Identifiable, Codable, Hashable {
    @DocumentID var id : String?
    var name: String
    var imageUrl: String
    var userId: String
    var recipeIds: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecipeCollection, rhs: RecipeCollection) -> Bool {
        lhs.id == rhs.id
    }
}
