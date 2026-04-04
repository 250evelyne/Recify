//
//  SearchResults.swift
//  Recify
//
//  Created by Macbook on 2026-03-08.
//

import SwiftUI

struct SearchResults: View {
    @StateObject var viewModel = HomeViewModel()
    let query: String
    let filters: SearchFilters
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.3),
                    Color.clear,
                    Color.pink.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            mainContentView
        }
//        mainContentView
            .navigationTitle("Results")
            .task {
                await viewModel.searchMeals(query: query, filters: filters)
            }
    }
    
    // MARK: - Subviews
    
    private var mainContentView: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                    Text("Searching for recipes...")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
            } else if viewModel.searchResults.isEmpty {
                emptyStateView
            } else {
                resultsListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No recipes found.")
                .font(.headline)
            Text("Try adjusting your filters or search terms.")
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var resultsListView: some View {
        ScrollView {
//            Text("\(viewModel.searchResults.count) recipes round for '\(query)'")
//                    .font(.title3)
//                    .foregroundColor(.black)
//                    .padding(.horizontal)
//                    .fontWeight(.semibold)
            
//            LazyVGrid(columns: [
//                GridItem(.flexible(), spacing: 16),
//                GridItem(.flexible(), spacing: 16)
//            ], spacing: 20) {
            
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.offset) { index, recipe in
                    NavigationLink(destination: RecipeInstructionsView(
                        mealId: recipe.id ?? recipe.title,
                        recipeTitle: recipe.title,
                        recipeImage: recipe.imageURL ?? "",
                        prepTime: recipe.prepTime,
                        difficulty: recipe.level,
                        recipe: recipe
                    )) {
                        searchResultCard(
                            mealId: recipe.id ?? "",
                            title: recipe.title,
                            imageURL: recipe.imageURL ?? "", 
                            time: recipe.prepTime,
                            difficulty: recipe.level
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
//            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
//        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SearchResults(
        query: "Chicken",
        filters: SearchFilters(
            cookTime: .under15,
            dietaryRestrictions: [.vegan],
            matchPantry: false
        )
    )
}
