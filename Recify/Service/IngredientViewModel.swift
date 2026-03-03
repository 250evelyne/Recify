//
//  IngredientViewModel.swift
//  Recify
//
//  Created by netblen on 2026-02-08.
//

import Foundation

class IngredientViewModel: ObservableObject {
    @Published var pagedIngredients: [Ingredients] = []
    @Published var isLoading: Bool = false
    
    private var activeFilter: Filters = .all
    private var allFetchedResults: [Ingredients] = []
    private let pageSize = 20
    private var currentIndex = 0
    private let service = IngredientsService()
    
    func searchIngredients(query: String) async {
        await MainActor.run { self.isLoading = true }
        
        let allIngredients = await service.fetchAllIngredients()
        
        let results = allIngredients.filter { ingredient in
            let matchesQuery = query.isEmpty || ingredient.name.localizedCaseInsensitiveContains(query)
            
            let matchesFilter = (activeFilter == .all) || (ingredient.category == activeFilter)
            
            return matchesQuery && matchesFilter
        }
        
        await MainActor.run {
            self.allFetchedResults = results
            self.pagedIngredients = Array(results.prefix(self.pageSize))
            self.currentIndex = self.pagedIngredients.count
            self.isLoading = false
        }
    }
    

    
    func loadNextPage() {
        let nextIndex = min(currentIndex + pageSize, allFetchedResults.count)
        guard currentIndex < nextIndex else { return }
        
        let newItems = allFetchedResults[currentIndex..<nextIndex]
        
        DispatchQueue.main.async {
            for item in newItems {
                //check if the name already exists in the paged list
                if !self.pagedIngredients.contains(where: { $0.name == item.name }) {
                    self.pagedIngredients.append(item)
                }
            }
            self.currentIndex = nextIndex
        }
    }
    
    
    func filterByCategory(filter: Filters) {
        //store the filter so the search function knows about it
        self.activeFilter = filter
        
        if filter == .all {
            self.pagedIngredients = Array(allFetchedResults.prefix(pageSize))
        } else {
            let filtered = allFetchedResults.filter { $0.category == filter }
            self.pagedIngredients = Array(filtered.prefix(pageSize))
        }
    }
    
    func determineCategory(name: String) -> Filters {
        let lowerName = name.lowercased()
        
        if ["water", "milk", "juice", "stock", "broth"].contains(where: lowerName.contains) {
            return .liquids 
        }
        
        if ["apple", "banana", "orange", "berry", "lemon"].contains(where: lowerName.contains) {
            return .fruits
        }
        
        return .vegetables
    }
    
    
    func refreshIngredients() async {
        await MainActor.run { self.isLoading = true }
        
        let results = await service.fetchAllIngredients(forceRefresh: true)
        
        await MainActor.run {
            self.allFetchedResults = results
            self.pagedIngredients = Array(results.prefix(20))
            self.isLoading = false
        }
    }
    
}
