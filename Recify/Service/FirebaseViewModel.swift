//
//  FirebaseViewModel.swift
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
    @Published var recipes: [Recipe] = []
    @Published var userRecipes: [Recipe] = [] //the recipes the user had postsed
    @Published var shoppingItems: [Ingredients] = []
    @Published var savedRecipes: [SavedRecipe] = []
    @Published var userFavCollections: [RecipeCollection] = [] //i added this to save the collections th users have made for thiere fav recipes
    @Published var currentCollectionRecipes: [SavedRecipe] = [] //i added this for the favorites page i dont use saved recipes i use this to i can just gett all the saved recioes
    
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
    
    func deleteRecipe(recipeId: String) {
        let db = Firestore.firestore()
        
        db.collection("recipes").document(recipeId).delete { error in
            if let error = error {
                print("Error deleting recipe: \(error.localizedDescription)")
            } else {
                print("Recipe deleted successfully")
                
                // 🔥 Update UI instantly
                DispatchQueue.main.async {
                    self.userRecipes.removeAll { $0.id == recipeId }
                }
            }
        }
    }
    
    func deleteIngredient(_ ingredient: Ingredients) {
        guard let collection = userCollection, let id = ingredient.id else { return }
        
        collection.document(id).delete() { [weak self] error in
            if let error = error {
                print("Error deleting: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.ingredients.removeAll { $0.id == id }
                }
            }
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
    
    @MainActor
    func loadUserRecipes() async {
        let recipes = await fetchUserRecipes()
        self.userRecipes = recipes
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
    //checks if the heart should be filled in or not
    func isRecipeSaved(mealId: String) -> Bool {
        return savedRecipes.contains(where: { $0.mealId == mealId })
    }
    

    func toggleFavorite(mealId: String, title: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let favRef = db.collection("users").document(userId).collection("favorites").document(mealId)
        
        if let existingIndex = savedRecipes.firstIndex(where: { $0.mealId == mealId }) {
            savedRecipes.remove(at: existingIndex)
            favRef.delete()
            
            for collection in userFavCollections {
                if collection.recipeIds.contains(mealId) {
                    removeFromCollection(recipeId: mealId, collectionTitle: collection.name)
                }
            }
        } else {
            let newFavorite = SavedRecipe(mealId: mealId, title: title, imageURL: imageURL)
            savedRecipes.append(newFavorite)
            try? favRef.setData(from: newFavorite)
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
    
    func saveToCollection(recipedId: String, collectionId: String) {
        if let collection = userFavCollections.first(where: { $0.id == collectionId }),
           collection.recipeIds.contains(recipedId) {
            print("DEBUG: Already saved in this collection")
            return
        }
        
        let collectionRef = db.collection("collections").document(collectionId)
        
        collectionRef.updateData([
            "recipeIds": FieldValue.arrayUnion([recipedId])
        ]) { error in
            if let error = error {
                print("Error saving to collection: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    if let index = self.userFavCollections.firstIndex(where: { $0.id == collectionId }) {
                        self.userFavCollections[index].recipeIds.append(recipedId)
                        print("Successfully added \(recipedId) to collection locally")
                    }
                }
            }
        }
    }
    
    
    func deleteCollection(_ collection: RecipeCollection){
        if let id = collection.id{
            Firestore.firestore()
                .collection("collections")
                .document(id)
                .delete()
        }
    }
    
    func fecthUsersCollections() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("collections")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: Error fetching collections: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                let collections = documents.compactMap { document -> RecipeCollection? in
                    try? document.data(as: RecipeCollection.self)
                }
                
                DispatchQueue.main.async {
                    self.userFavCollections = collections
                }
                
//                self.userFavCollections = documents.compactMap { document in
//                    do {
//                        // This line is the ultimate test
//                        let result = try document.data(as: RecipeCollection.self)
//                        print("af DEBUG: Successfully decoded: \(result.name)")
//                        return result
//                    } catch {
//                        print("Decoding failed for \(document.documentID): \(error)")
//                        // This print will tell us EXACTLY which field is causing the crash
//                        return nil
//                    }
//                }
            }
    }
    
    
    func fetchRecipesForCollection(ids: [String]) {
        self.currentCollectionRecipes = []
        guard !ids.isEmpty else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: User not logged in")
            return
        }
        
        print("DEBUG: Fetching from FAVORITES for IDs: \(ids)")
        
        db.collection("users").document(userId).collection("favorites")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: Firestore Error: \(error.localizedDescription)")
                    return
                }
                
                if let docs = querySnapshot?.documents {
                    let fetched = docs.compactMap { try? $0.data(as: SavedRecipe.self) }
                    print("DEBUG: Final fetched count: \(fetched.count)")
                    
                    DispatchQueue.main.async {
                        self.currentCollectionRecipes = fetched
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
        
        return .other
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
    
    func removeFromCollection(recipeId: String, collectionTitle: String) {
        guard let collection = userFavCollections.first(where: { $0.name == collectionTitle }),
              let collectionId = collection.id else { return }
        
        db.collection("collections").document(collectionId).updateData([
            "recipeIds": FieldValue.arrayRemove([recipeId])
        ]) { error in
            if error == nil {
                DispatchQueue.main.async {
                    if let index = self.userFavCollections.firstIndex(where: { $0.id == collectionId }) {
                        self.userFavCollections[index].recipeIds.removeAll { $0 == recipeId }
                    }
                }
            }
        }
    }
    
    // MARK: - Post New Recipe
    func saveNewRecipe(title: String,
                       caloriesString: String,
                       prepTime: Int,
                       difficulty: String,
                       ingredients: [Ingredients],
                       instructionsArray: [String],
                       coverImage: UIImage?,
                       completion: @escaping (Bool) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            completion(false)
            return
        }
        
        var base64String: String? = nil
        if let image = coverImage {
            if let imageData = image.jpegData(compressionQuality: 0.05) {
                base64String = imageData.base64EncodedString()
            }
        }
        
        let caloriesInt = Int(caloriesString.filter { $0.isWholeNumber }) ?? 0
        let ingredientStrings = ingredients.map { $0.displayText }
        let formattedInstructions = instructionsArray.joined(separator: "\n")
        
        let newRecipe = Recipe(
            title: title.isEmpty ? "Untitled Recipe" : title,
            category: "General",
            ingredients: ingredientStrings,
            instructions: formattedInstructions,
            imageURL: base64String,
            servings: 2,
            userId: userId,
            inPantry: false,
            prepTime: prepTime,
            calories: caloriesInt,
            level: difficulty.capitalized,
            searchTitle: title.lowercased()
        )
        
        do {
            try db.collection("recipes").document().setData(from: newRecipe)
            print("Successfully saved recipe with Base64 image!")
            completion(true)
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
    func searchUserRecipes(query: String) async -> [Recipe] {
        let db = Firestore.firestore()
        let lowerQuery = query.lowercased()
        
        do {
            let snapshot = try await db.collection("recipes")
                .whereField("searchTitle", isGreaterThanOrEqualTo: lowerQuery) 
                .whereField("searchTitle", isLessThanOrEqualTo: lowerQuery + "\u{f8ff}")
                .getDocuments()
            
            return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
        } catch {
            print("Error searching Firebase: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func fetchUserRecipes() async -> [Recipe] {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            return []
        }
        
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("recipes")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            let recipes = snapshot.documents.compactMap {
                try? $0.data(as: Recipe.self)
            }
            
            return recipes
        } catch {
            print("Error fetching user recipes: \(error.localizedDescription)")
            return []
        }
    }
    
}
