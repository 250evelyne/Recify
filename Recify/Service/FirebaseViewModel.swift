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
    @Published var isLoading: Bool = false
    @Published var canLoadMore: Bool = true //track if there are more items to fetch
    
    //keeps track of the last document fetched for pagination
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 20
    
    init(){
        //initial load
        fetchIngredients()
    }
    
    func fetchIngredients() {
        //prevent multiple simultaneous loads or loading if we reached the end
        guard !isLoading && canLoadMore else { return }
        
        isLoading = true
        
        var query: Query = db.collection("ingredients").order(by: "name").limit(to: pageSize)
        
        //if we already have a last document, start the next query after it
        if let lastCursor = lastDocument {
            query = query.start(afterDocument: lastCursor)
        }
        
        // Using getDocuments for pagination rather than addSnapshotListener
        // to have better control over "chunks" and manual triggers
        query.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching ingredients: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                self.canLoadMore = false //no more data to load
                return
            }
            
            //save the last document for the next pagination call
            self.lastDocument = documents.last
            
            let newIngredients = documents.compactMap({ document in
                try? document.data(as: Ingredients.self)
            })
            
            //append the new "chunk" to the existing list
            DispatchQueue.main.async {
                self.ingredients.append(contentsOf: newIngredients)
                
                //if we got fewer items than the page size, we reached the end
                if documents.count < self.pageSize {
                    self.canLoadMore = false
                }
            }
        }
    }
    
    //call this to reset and reload from scratch
    func refreshData() {
        lastDocument = nil
        ingredients = []
        canLoadMore = true
        fetchIngredients()
    }
    
    
    func addIngredient(name: String, imageUrl: String, category: Filters, quantity: Int, unit: units) {
        let docId = name.lowercased().trimmingCharacters(in: .whitespaces)
        if let existingIngredient = ingredients.first(where: { $0.id == docId }) {
            updateQuantity(ingredient: existingIngredient, change: quantity)
        } else {
            let newIngredient = Ingredients(name: name, quantity: quantity, unit: unit, imageUrl: imageUrl, category: category)
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
            db.collection("ingredients").document(id).updateData(["quantity": newQuantity])
        } else if newQuantity <= 0 {
            db.collection("ingredients").document(id).delete()
            // Remove from local list to keep UI in sync after deletion
            self.ingredients.removeAll { $0.id == id }
        }
    }
}
