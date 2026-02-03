//
//  Recipe.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//
import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var category: String
    var ingredients: [String]
    var instructions: [String]
    var servings: Int
    var timeMinutes: Int
    var userId: String
    
    init(id: String? = nil, title: String, category: String, ingredients: [String], instructions: [String], servings: Int, timeMinutes: Int, userId: String) {
        self.id = id
        self.title = title
        self.category = category
        self.ingredients = ingredients
        self.instructions = instructions
        self.servings = servings
        self.timeMinutes = timeMinutes
        self.userId = userId
    }
}
