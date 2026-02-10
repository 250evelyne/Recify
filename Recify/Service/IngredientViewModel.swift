//
//  IngredientViewModel.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
//

import Foundation


class IngredientViewModel: ObservableObject {
    @Published var ingredients: [Ingredients] = []
    
//    @Published var isLoading: Bool = false ///remeber to add a cirlce porgress bar thingy to the app
  //  @Published var errorMessage: String?
    
    private let service = IngredientsService()
    private let firebase = FirebaseViewModel.shared
    
//    func loadIngredients() async {
//        isLoading = true
//        errorMessage = nil
//        let result = await service.fetchIngredients()
//        let ingredients = result
//        isLoading = false
//    }
        
    /// ima add the units and uanityty so maybe we can reuse this for when we adding the ingredients to the uers pantry
    /// in the furture caus ei cant figure it out rn but wed just have the id of the ingredient as a foren key then wed get the name image url and cat
    /// so when adding ingredients to the uesrs pantry idk if i should create a new func(pobably) cause i wouldnt need half the paraneters
    
//    func addIngredient(name: String, imageUrl: String, category: Filters) async {
//        errorMessage = nil
//        if let created = await service.createIngredient(name: name, imageUrl: imageUrl, category: category){
//            ingredients.append(created)
//        }else{
//            errorMessage = "Failed to create ingredient"
//        }
//        
//    }
//    
    
    func uploadingIngredientsToFirebase() async {
        let apiIngredients = await service.fetchIngredients()
        
        for apiIngredient in apiIngredients {
            let name = apiIngredient.name
            let image = apiIngredient.image
            let category = autoAssignCategory(from: name)
            
            firebase.addIngredient(name: name, imageUrl: image, category: category)
        }
    }
    
    
    ///since the api im using doent give categories for the ingredients ina try and mapp them by looking for key words
    func autoAssignCategory(from name: String) -> Filters {
        let lower = name.lowercased()

        if lower.contains("beef") || lower.contains("chicken") || lower.contains("pork") {
            return .proteins
        } else if lower.contains("milk") || lower.contains("cheese") {
            return .dairy
        } else if lower.contains("rice") || lower.contains("pasta") {
            return .grains
        } else if lower.contains("oil") {
            return .oils
        } else {
            return .vegetables
        }
    }
    
    
}

