//
//  FirebaseViewModel.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
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

    func addIngredient(name: String, imageUrl: String, category: Filters){
        let newIngredient = Ingredients(name: name, imageUrl: imageUrl, category: category)
        
        do{
            try db.collection("ingredients").addDocument(from: newIngredient) ///where i puse it to the firestore
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
}
