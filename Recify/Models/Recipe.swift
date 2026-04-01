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
    //TODO: we need to add ijages to the firebaseif there aisnt nay why of saving them yeyt idk
    var servings: Int
    var timeMinutes: Int
    var userId: String
    var dificulty : Difficulty? //ig they dont need to put it
    
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


enum Difficulty: String, Codable, CaseIterable{
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
// idk if i should make a new enum for thsi as like levels or wtv
//    case beginner = "Beginner"
//    case intermidiate = "Intermidiate"
//    case advanced = "Advanced"
}
