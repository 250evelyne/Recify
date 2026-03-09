//
//  SavedRecipe.swift
//  Recify
//
//  Created by netblen on 09-03-2026.
//

import Foundation
import FirebaseFirestore

struct SavedRecipe: Identifiable, Codable {
    @DocumentID var id: String?
    let mealId: String
    let title: String
    let imageURL: String
    var dateAdded: Date = Date()
}
