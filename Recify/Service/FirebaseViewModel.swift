//
//  IngredientsService.swift
//  Recify
//
//  Created by netblen on 2026-02-08.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class FirebaseViewModel: ObservableObject {
    static let shared = FirebaseViewModel()
    private let db = Firestore.firestore()
    
    @Published var ingredients : [Ingredients] = []
    @Published var isLoading: Bool = false
    @Published var canLoadMore: Bool = true
    
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 20
    
    
    func fetchIngredients() {
        guard let collection = userCollection, !isLoading && canLoadMore else { return }
        
        isLoading = true
        var query: Query = collection.order(by: "name").limit(to: pageSize)
        
        if let lastCursor = lastDocument {
            query = query.start(afterDocument: lastCursor)
        }
        
        query.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching ingredients: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                self.canLoadMore = false
                return
            }
            
            self.lastDocument = documents.last
            let newIngredients = documents.compactMap({ try? $0.data(as: Ingredients.self) })
            
            DispatchQueue.main.async {
                self.ingredients.append(contentsOf: newIngredients)
                if documents.count < self.pageSize {
                    self.canLoadMore = false
                }
            }
        }
    }
    
    func addIngredient(name: String, imageUrl: String, category: Filters, quantity: Int, unit: units) {
        guard let collection = userCollection else { return }
        let docId = name.lowercased().trimmingCharacters(in: .whitespaces)
        
        if let existingIngredient = ingredients.first(where: { $0.id == docId }) {
            updateQuantity(ingredient: existingIngredient, change: quantity)
        } else {
            let newIngredient = Ingredients(name: name, quantity: quantity, unit: unit, imageUrl: imageUrl, category: category)
            do {
                try collection.document(docId).setData(from: newIngredient)
                self.refreshData()
            } catch {
                print("Error saving ingredient: \(error.localizedDescription)")
            }
        }
    }
    
    func updateQuantity(ingredient: Ingredients, change: Int) {
        guard let collection = userCollection, let id = ingredient.id else { return }
        let currentQuantity = ingredient.quantity ?? 0
        let newQuantity = currentQuantity + change
        
        if newQuantity > 0 {
            collection.document(id).updateData(["quantity": newQuantity])
            if let index = self.ingredients.firstIndex(where: { $0.id == id }) {
                self.ingredients[index].quantity = newQuantity
            }
        } else {
            collection.document(id).delete()
            self.ingredients.removeAll { $0.id == id }
        }
    }
    
    func refreshData() {
        lastDocument = nil
        ingredients = []
        canLoadMore = true
        fetchIngredients()
    }
    
    private var userCollection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user ID found - user is not logged in.")
            return nil
        }
        return db.collection("users").document(uid).collection("ingredients")
    }
}
