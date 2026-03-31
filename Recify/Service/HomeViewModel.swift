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
    @Published var pantrySubtitle: String = "Loading..."
    @Published var isSearching = false
    @Published var hasNoResults = false
    @Published var recipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var selectedFilters = SearchFilters()
    @Published var filteredRecipes: [Recipe] = []
    @Published var searchResults: [Recipe] = []
    @Published var isLoading: Bool = false
    
    var ingredientViewModel = IngredientViewModel()
    
    private let webService = WebService()

    
    @MainActor
    func applySearch() {
        self.isSearching = true
        
        Task {
            let results = await webService.fetchFilteredRecipes(
                query: searchText,
                filters: selectedFilters
            )
            
            self.recipes = results
            self.isSearching = false
            
            self.hasNoResults = results.isEmpty && !searchText.isEmpty
        }
    }
    
    func searchMeals(query: String, filters: SearchFilters) async {
        
        //here are they clearing the Home search bar, or using Advanced Filters so the search works smoothly
        let noFiltersActive = filters.cookTime == nil && filters.dietaryRestrictions.isEmpty && !filters.matchPantry
        
        if query.isEmpty && noFiltersActive {
            //update results and THEN apply secondary pantry filters
            await MainActor.run {
                self.searchResults = []
                self.hasNoResults = false
                self.isSearching = false
            }
            return
        }
        
        await MainActor.run {
            self.isSearching = true
            self.hasNoResults = false
        }
        
        let results = await WebService().fetchFilteredRecipes(query: query, filters: filters)
        
        //update results and THEN apply secondary pantry filters
        await MainActor.run {
            self.searchResults = results
            
            //only run pantry logic if the user actually turned it on
            if filters.matchPantry {
                self.applyAdvancedFilters(filters: filters)
            }
            
            self.isSearching = false
            self.hasNoResults = self.searchResults.isEmpty
        }
    }
    
    
    private func fetchPantryMatch() async {
        let userPantry = FirebaseViewModel.shared.ingredients
        
        if let randomIngredient = userPantry.randomElement()?.name {
            let formattedIngredient = randomIngredient.replacingOccurrences(of: " ", with: "_").lowercased()
            let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(formattedIngredient)"
            
            if let meals = await fetchMeals(from: urlString), !meals.isEmpty {
                self.pantryMeals = Array(meals.prefix(5))
                self.pantrySubtitle = "Using your \(randomIngredient)"
                return
            }
        }
        
        let fallbackUrlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=Chicken" 
        if let fallbackMeals = await fetchMeals(from: fallbackUrlString) {
            self.pantryMeals = Array(fallbackMeals.prefix(5))
            self.pantrySubtitle = "Add items to your pantry for custom matches!"
        }
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
    
    
    func filterResults(results: [Recipe], filters: SearchFilters, pantryIngredients: [Ingredients]) {
        self.filteredRecipes = results.filter { recipe in
            let pantryMatch: Bool
            if filters.matchPantry {
                let pantryNames = pantryIngredients.compactMap {
                    $0.name.lowercased()
                }
                // Check if recipe ingredients exist in pantry
                let matches = recipe.ingredients.filter { ing in
                    pantryNames.contains(where: { $0.contains(ing.lowercased()) })
                }
                pantryMatch = !matches.isEmpty
            } else {
                pantryMatch = true
            }
            
            //match Dietary Restrictions
            let dietMatch = filters.dietaryRestrictions.isEmpty || filters.dietaryRestrictions.allSatisfy { diet in
                diet.matches(category: recipe.category, ingredients: recipe.ingredients)
            }
            
            return pantryMatch && dietMatch
        }
    }
    
    func searchRecipes(query: String) async {
        self.isLoading = true
        // self.searchResults = await WebService.shared.fetch(query: query)
        self.isLoading = false
    }
    
    
    func applyAdvancedFilters(filters: SearchFilters) {
        // If the toggle is OFF, stop here and keep all results
        guard filters.matchPantry else {
            print("✅ Filters are OFF, skipping filtering logic")
            return
        }
        
        let pantryIngredients = FirebaseViewModel.shared.ingredients.map { $0.name.lowercased() }
        
        self.searchResults = self.searchResults.filter { recipe in
            if recipe.ingredients.isEmpty { return true }
            
            let recipeIngs = recipe.ingredients.map { $0.lowercased() }
            
            return recipeIngs.contains { recipeIng in
                pantryIngredients.contains { pantryIng in
                    recipeIng.contains(pantryIng) || pantryIng.contains(recipeIng)
                }
            }
        }
    }

    func fetchHomeData() async {
        self.isLoading = true
        
        async let pantryTask: () = fetchPantryMatch()
        async let trendingTask: () = fetchTrendingMeals()
        
        _ = await [pantryTask, trendingTask]
        
        self.isLoading = false
    }
}
