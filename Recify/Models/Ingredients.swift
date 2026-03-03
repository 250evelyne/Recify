//
//  Ingredients.swift
//  Recify
//
//  Created by Macbook on 2026-02-07.
//

import Foundation
import FirebaseFirestore

struct Ingredients: Identifiable, Codable{ //, Codable , says its not conforming to decodable rn so add later when i do the fetch for the api
    @DocumentID var id: String? //for firestore
    var apiId: String?
    var name: String
    var quantity : Int? //when i get them from the api there isnt gonna be a quantity or unit
    var unit : units?
    var imageUrl: String
    var category: Filters? //check if i have top ut this as nil for when i first get the list of ingredients since they dont have cateogries?
    var isChecked: Bool? = false //have to add this to make the shooping work
    var timestamp: Date? //same here
}


enum units: String, CaseIterable ,Identifiable, Codable{
    
    var id:Self {self}

    case pcs = "pcs"
    case grams = "grams"
    case kg = "kg"
    case ml = "ml"
    case liters = "liters"
    case cups = "cups"
    case oz = "oz"
    case pounds = "lbs"
}
