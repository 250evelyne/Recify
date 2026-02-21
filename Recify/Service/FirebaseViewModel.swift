//
//  IngredientsService.swift
//  Recify
//
//  Created by netblen on 2026-02-08.
//

import Foundation
import Combine
import FirebaseFirestore

class FirebaseViewModel: ObservableObject {
    
    static let shared = FirebaseViewModel()
    private let db = Firestore.firestore()
    
    @Published var ingredients : [Ingredients] = []
    
    init(){
        fetchIngredients()
    }
    
    func fetchIngredients(){
        db.collection("ingredients").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.ingredients = querySnapshot?.documents.compactMap({ document in
                try? document.data(as: Ingredients.self)
            }) ?? []
        }
    }
    
    func addIngredient(name: String, imageUrl: String, category: Filters, quantity: Int, unit: units) {
        let docId = name.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check if the ingredient already exists in the local list
        if let existingIngredient = ingredients.first(where: { $0.id == docId }) {
            //if it exists, just update the quantity by adding the new amount
            updateQuantity(ingredient: existingIngredient, change: quantity)
        } else {
            //if it doesn't exist, create a new document
            let newIngredient = Ingredients(
                name: name,
                quantity: quantity,
                unit: unit,
                imageUrl: imageUrl,
                category: category
            )
            
            do {
                try db.collection("ingredients").document(docId).setData(from: newIngredient)
            } catch {
                print("Error saving ingredient: \(error.localizedDescription)")
            }
        }
    }
    
    func updateQuantity(ingredient: Ingredients, change: Int) {
        guard let id = ingredient.id else { return }
        let currentQuantity = ingredient.quantity ?? 0
        let newQuantity = currentQuantity + change
        
        if newQuantity > 0 {
            db.collection("ingredients").document(id).updateData([
                "quantity": newQuantity
            ]) { error in
                if let error = error {
                    print("Error updating quantity: \(error.localizedDescription)")
                }
            }
        } else if newQuantity <= 0 {
            db.collection("ingredients").document(id).delete() { error in
                if let error = error {
                    print("Error deleting ingredient: \(error.localizedDescription)")
                }
            }
        }
    }
}
