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
    @Published var shoppingItems: [Ingredients] = []
    @Published var savedRecipes: [SavedRecipe] = []
    @Published var userFavCollections: [RecipeCollection] = [] //i added this to save the collections th users have made for thiere fav recipes
    @Published var currentCollectionRecipes: [Recipe] = [] //i added this for the favorites page i dont use saved recipes i use this to i can just gett all the saved recioes
    
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 20
    
    
    func fetchRecipes(searchQuery: String) {
        db.collection("recipes")
            .whereField("name", isGreaterThanOrEqualTo: searchQuery)
            .whereField("name", isLessThanOrEqualTo: searchQuery + "\u{f8ff}") //searching for names that start with he qesry
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching recipes: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.savedRecipes = documents.compactMap { doc in
                    try? doc.data(as: SavedRecipe.self)
                }
            }
    }
    
    //TODO: see if it works
    func deleteIngredient(_ ingredient: Ingredients) {
        if let id = ingredient.id {
            Firestore.firestore()
                .collection("ingredients")
                .document(id)
                .delete()
        }
    }
    
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
        fetchShoppingList()
        fetchSavedRecipes()
        fecthUsersCollections()
    }
    
    private var userCollection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user ID found - user is not logged in.")
            return nil
        }
        return db.collection("users").document(uid).collection("ingredients")
    }
    
    
    //MARK: Shopping
    func addToShoppingList(name: String, imageUrl: String, category: Filters, quantity: Int, unit: units, recipeName: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let docId = name.lowercased().trimmingCharacters(in: .whitespaces)
        let docRef = db.collection("users").document(userId).collection("shopping_list").document(docId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentQuantity = document.data()?["quantity"] as? Int ?? 0
                docRef.updateData([
                    "quantity": currentQuantity + quantity,
                    "timestamp": FieldValue.serverTimestamp()
                ])
            } else {
                let shoppingItem: [String: Any] = [
                    "name": name,
                    "imageUrl": imageUrl,
                    "category": category.rawValue,
                    "quantity": quantity,
                    "unit": unit.rawValue,
                    "isChecked": false,
                    "timestamp": FieldValue.serverTimestamp(),
                    "recipeName": recipeName ?? ""
                ]
                docRef.setData(shoppingItem)
            }
        }
    }
    
    func fetchShoppingList() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("shopping_list")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                self.shoppingItems = documents.compactMap { doc -> Ingredients? in
                    do {
                        return try doc.data(as: Ingredients.self)
                    } catch {
                        print("Debuging error for \(doc.documentID): \(error)") //just to debug wahts going on
                        return nil
                    }
                }
            }
    }
        
    func clearCompletedShoppingItems(items: [Ingredients]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        for item in items {
            if let documentId = item.id {
                db.collection("users").document(userId).collection("shopping_list").document(documentId).delete() { error in
                    if let error = error {
                        print("Error removing document: \(error)")
                    }
                }
            }
        }
    }
    
    func toggleShoppingItemCheck(item: Ingredients) {
        guard let userId = Auth.auth().currentUser?.uid, let docId = item.id else { return }
        let db = Firestore.firestore()
        
        let currentStatus = item.isChecked ?? false
        
        db.collection("users").document(userId).collection("shopping_list").document(docId).updateData([
            "isChecked": !currentStatus
        ])
    }
    
    //MARK: favorites
    // Checks if the heart should be filled in or not
    func isRecipeSaved(mealId: String) -> Bool {
        return savedRecipes.contains(where: { $0.mealId == mealId })
    }
    
    func toggleFavorite(mealId: String, title: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let favRef = db.collection("users").document(userId).collection("favorites").document(mealId)
        
        if let existingIndex = savedRecipes.firstIndex(where: { $0.mealId == mealId }) {
            savedRecipes.remove(at: existingIndex)
            
            favRef.delete()
        } else {
            //add to local array to update UI instantly
            let newFavorite = SavedRecipe(mealId: mealId, title: title, imageURL: imageURL)
            savedRecipes.append(newFavorite)
            
            do {
                try favRef.setData(from: newFavorite)
            } catch {
                print("Error saving favorite: \(error)")
            }
        }
    }
    

    func fetchSavedRecipes() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("favorites")
            .order(by: "dateAdded", descending: true) //shows newest favorites firs
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                self.savedRecipes = documents.compactMap { doc -> SavedRecipe? in
                    try? doc.data(as: SavedRecipe.self)
                }
            }
    }
    

    
    
    //MARK: fav collections
    
    func saveNewCollection (name: String, imageUrl: String){
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let newCollection : [String : Any] = [
            "name" : name,
            "imageUrl" : imageUrl,
            "userId" : userId,
            "recipeIds" : [] //just the collections created we dont have any recioes in ti
        ]
        
        db.collection("collections").addDocument(data: newCollection) {error in
            if let error = error {
                print("Error saving: \(error.localizedDescription)")
            } else {
                print("Successfully created \(name)!")
            }
            
        }
        
    }
    
    func saveToCollection(recipedId: String, collectionId: String){
        
        let collectionRef = db.collection("collections").document(collectionId)
        
        collectionRef.updateData([
            "recipeIds" : FieldValue.arrayUnion([recipedId])
        ]){ error in
            if let error = error{
                
                print("Error adding recipe to collection: \(error.localizedDescription)")
            } else {
                print("Successfully added recipe \(recipedId) to collection \(collectionId)!")
            }
        }
        
    }
    
    func fecthUsersCollections() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: No User Logged In. Auth is nil.")
            return
        }
        
        print("DEBUG: Starting fetch for UID: \(userId)")
        
        db.collection("collections")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Firestore Error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    return
                }
                
                
                self.userFavCollections = documents.compactMap { document in
                    do {
                        // This line is the ultimate test
                        let result = try document.data(as: RecipeCollection.self)
                        print("af DEBUG: Successfully decoded: \(result.name)")
                        return result
                    } catch {
                        print("Decoding failed for \(document.documentID): \(error)")
                        // This print will tell us EXACTLY which field is causing the crash
                        return nil
                    }
                }
            }
    }
    
    func fetchRecipesForCollection(ids: [String]) {
        // 1. Check if empty
        guard !ids.isEmpty else {
            print("DEBUG: IDs array is empty, skipping fetch.")
            self.currentCollectionRecipes = []
            return
        }

        // 2. Limit to 10 (Firestore 'in' query limit)
        let limitedIds = Array(ids.prefix(10))
        print("DEBUG: Fetching full details for: \(limitedIds)")

        db.collection("recipes")
            .whereField(FieldPath.documentID(), in: limitedIds)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("DEBUG: Firestore Error: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("DEBUG: No documents found for these IDs.")
                    return
                }

                print("DEBUG: Successfully fetched \(documents.count) full recipe documents.")

                self.currentCollectionRecipes = documents.compactMap { doc in
                    do {
                        return try doc.data(as: Recipe.self)
                    } catch {
                        print("DEBUG: Failed to decode recipe \(doc.documentID): \(error)")
                        return nil
                    }
                }
            }
    }
    
    
    
    //MARK: ingredients management
    func getCategory(for ingredient: String) -> Filters {
        let name = ingredient.lowercased()
        
        if name.contains("juice") || name.contains("milk") || name.contains("water") || name.contains("oil") {
            return .liquids
        } else if name.contains("chicken") || name.contains("beef") || name.contains("pork") || name.contains("steak") || name.contains("egg") {
            return .proteins
        } else if name.contains("onion") || name.contains("garlic") || name.contains("tomato") || name.contains("pepper") {
            return .vegetables
        }
        
        return .other // Fallback for everything else
    }
    
    
        
    func moveRecipeItemsToPantry(recipeName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let itemsToMove = shoppingItems.filter {
            $0.recipeName == recipeName && ($0.isChecked ?? false)
        }
        
        for item in itemsToMove {
            addIngredient(
                name: item.name,
                imageUrl: item.imageUrl,
                category: item.category ?? .other,
                quantity: item.quantity ?? 1,
                unit: item.unit ?? .pcs
            )
            
            if let docId = item.id {
                db.collection("users").document(userId).collection("shopping_list").document(docId).delete()
            }
        }
    }
    
    
    func moveCategoryItemsToPantry(category: Filters) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let itemsToMove = shoppingItems.filter {
            $0.category == category && ($0.isChecked ?? false)
        }
        
        for item in itemsToMove {
            addIngredient(
                name: item.name,
                imageUrl: item.imageUrl,
                category: item.category ?? .other,
                quantity: item.quantity ?? 1,
                unit: item.unit ?? .pcs
            )
            
            if let docId = item.id {
                db.collection("users").document(userId).collection("shopping_list").document(docId).delete()
            }
        }
    }
    
    
    
    
}
