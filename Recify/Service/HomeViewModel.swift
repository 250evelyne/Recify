//
//  HomeViewModel.swift
//  Recify
//
//  Created by netblen on 08-03-2026.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var pantryMeals: [MealApi] = []
    @Published var trendingMeals: [MealApi] = []
    @Published var isLoading = false
    @Published var pantrySubtitle: String = "Loading..."
    @Published var searchResults: [MealApi] = []
    @Published var isSearching = false
    @Published var hasNoResults = false 
    
    func searchMeals(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.searchResults = []
            self.hasNoResults = false
            return
        }
        
        isSearching = true
        hasNoResults = false
        
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s=\(formattedQuery)"
        
        if let meals = await fetchMeals(from: urlString), !meals.isEmpty {
            self.searchResults = meals
            self.hasNoResults = false
        } else {
            self.searchResults = []
            self.hasNoResults = true
        }
        
        isSearching = false
    }
    
    func fetchHomeData() async {
        isLoading = true
        
        //fetch Personalized Pantry Meals
        await fetchPantryMatch()
        
        //fetch Trending Meals - but we using beed section as trending
        await fetchTrendingMeals()
        
        isLoading = false
    }
    
    private func fetchPantryMatch() async {
        let userPantry = FirebaseViewModel.shared.ingredients
        
        // If the user has ingredients, pick a random one to search with
        if let randomIngredient = userPantry.randomElement()?.name {
            let formattedIngredient = randomIngredient.replacingOccurrences(of: " ", with: "_").lowercased()
            let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(formattedIngredient)"
            
            if let meals = await fetchMeals(from: urlString), !meals.isEmpty {
                self.pantryMeals = Array(meals.prefix(5))
                self.pantrySubtitle = "Using your \(randomIngredient)"
                return
            }
        }
        
        // FALLBACK: If the pantry is empty OR the API couldn't find a meal with that ingredient
        let fallbackUrlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=Chicken" // Default category
        if let fallbackMeals = await fetchMeals(from: fallbackUrlString) {
            self.pantryMeals = Array(fallbackMeals.prefix(5))
            self.pantrySubtitle = "Add items to your pantry for custom matches!"
        } ///notsure
    }
    
    private func fetchTrendingMeals() async {
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=Beef"
        if let meals = await fetchMeals(from: urlString) {
            self.trendingMeals = Array(meals.prefix(10))
        }
    }
    
    private func fetchMeals(from urlString: String) async -> [MealApi]? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(MealResponse.self, from: data)
            return decodedResponse.meals
        } catch {
            print("Network request failed: \(error)")
            return nil
        }
    }
}
