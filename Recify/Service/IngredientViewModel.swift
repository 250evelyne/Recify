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
    
    private var allFetchedResults: [Ingredients] = []
    private let pageSize = 20
    private var currentIndex = 0
    private let service = IngredientsService()
    
    func searchIngredients(query: String) async {
        await MainActor.run { self.isLoading = true }
        
        let allIngredients = await service.fetchAllIngredients()
        
        let task = Task.detached(priority: .userInitiated) {
            if query.isEmpty {
                return allIngredients
            }
            
            // Check against both name and category for better filtering
            return allIngredients.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.category?.rawValue.localizedCaseInsensitiveContains(query) ?? false
            }
        }
        
        let results = await task.value
        
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
            self.pagedIngredients.append(contentsOf: Array(newItems))
            self.currentIndex = nextIndex
        }
    }
}
