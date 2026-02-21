//
//  IngredientsService.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
//

import Foundation

enum HttpMethod: String {
    case GET, POST, PUT, DELETE
}

class IngredientsService {
    
    // Define the webService and baseUrl within the class scope
    private let webService = WebService()
    private let baseUrl = "https://www.themealdb.com/api/json/v1/1/list.php?i=list"
    
    func fetchIngredients() async -> [IngredientApi] {
        let result: IngredientResponse? = await webService.sendRequest(toUrl: baseUrl, method: HttpMethod.GET)
        
        return result?.meals ?? []
    }
}
    
//    let id: Int?
//    let name: String
//    var quantity : Int?
//    var unit : units?
//    let imageUrl: String
//    let category: Filters?
    
    
    /* wrong i dont need this
    func createIngredient(name: String, imageUrl: String, category: Filters) async -> Ingredients? {
        
        let newIngredient = Ingredients(id: nil, name: name, imageUrl: imageUrl, category: category)
        
        
        let created : Ingredients? = await webService.sendRequest(toUrl: baseUrl, method: .POST, body: newIngredient)
        
        return created
    }*/
    
    
    /* wrong i dont need this
    func updateIngredient(_ ingredient: Ingredients) async -> Ingredients? {
        
        guard let id = ingredient.id else{
            print("Missing id for update")
            return nil
        }
        
        let url = "\(baseUrl)/\(id)"
        
        let updated : Ingredients? = await webService.sendRequest(toUrl: url, method: .PUT, body: ingredient)
        
        return updated
    }*/
    
    
    

