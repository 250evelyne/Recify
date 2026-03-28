//
//  HomeView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText: String = ""
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Search Bar & Filter (Always Visible)
                    searchBarSection
                    
                    // MARK: - Dynamic Content Area
                    // If searching, show the search loader
                    if viewModel.isSearching {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                        
                        // If we have search results, ONLY show the search results grid
                    }
                    else if viewModel.hasNoResults {
                        noResultsView
                    }
                    else if !viewModel.searchResults.isEmpty {
                        searchResultsGrid
                        
                    } else {
                        
                        //Loading thing
                        if viewModel.isLoading {
                            ProgressView("Loading Recipes...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        }
                        
                        // Pantry Match Section
                        if !viewModel.pantryMeals.isEmpty {
                            pantryMatchSection
                        }
                        
                        // Trending Now Section
                        if !viewModel.trendingMeals.isEmpty {
                            trendingSection
                        }
                    } 
                    
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.pink)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ShoppingList()) {
                        Image(systemName: "cart.fill")
                    }
                }
            }
            // Fetch data when the view appears
            .task {
                if viewModel.pantryMeals.isEmpty && viewModel.trendingMeals.isEmpty {
                    await viewModel.fetchHomeData()
                }
            }
        }
    }
    
    // MARK: - Extracted Subviews
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search recipes (e.g., Chicken)", text: $searchText)
                    .autocapitalization(.none)
                    .onSubmit {
                        Task {
                            await viewModel
                                .searchMeals(query: searchText, filters: SearchFilters())
                        }
                    }
                    .onChange(of: searchText) { newValue in
                        if newValue.isEmpty {
                            viewModel.searchResults = []
                            viewModel.hasNoResults = false
                        }
                    }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            NavigationLink {
                AdvanceSearchFiltersView()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.pink)
                    .frame(width: 50, height: 50)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 8)
            
            Text("No results found")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("We couldn't find any recipes for \"\(searchText)\".")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 60)
    }
    
    private var searchResultsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Search Results", subtitle: "Found \(viewModel.searchResults.count) recipes", icon: "magnifyingglass", iconColor: .pink)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(viewModel.searchResults) { recipe in
                    NavigationLink(destination: RecipeInstructionsView(
                        mealId: recipe.id ?? "",
                        recipeTitle: recipe.title,
                        recipeImage: recipe.imageUrl ?? "",
                        prepTime: recipe.prepTime,
                        difficulty: recipe.level
                    )){
                        RecipeCard(
                            title: recipe.title,
                            imageURL: recipe.imageUrl ?? "",
                            time: "\(recipe.prepTime)m",
                            difficulty: recipe.level,
                            matchPercentage: nil,
                            recipe: recipe
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    private var pantryMatchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Perfect for your Pantry", subtitle: viewModel.pantrySubtitle, icon: "sparkles", iconColor: .yellow)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.pantryMeals) { meal in
                        NavigationLink(destination: RecipeInstructionsView(
                            mealId: meal.idMeal,
                            recipeTitle: meal.strMeal ?? "Unknown Recipe",
                            recipeImage: meal.strMealThumb ?? "",
                            prepTime: 30,
                            difficulty: "Medium"
                        )) {
                            RecipeCard(
                                title: meal.strMeal ?? "Unknown Recipe",
                                imageURL: meal.strMealThumb ?? "",
                                time: "30m",
                                difficulty: "Medium",
                                matchPercentage: 85,
                                recipe: nil
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Trending Now", subtitle: "Popular picks for you", icon: "flame.fill", iconColor: .pink)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(viewModel.trendingMeals) { meal in
                    NavigationLink(destination: RecipeInstructionsView(
                        mealId: meal.idMeal ?? "",
                        recipeTitle: meal.strMeal ?? "Unknown Recipe",
                        recipeImage: meal.strMealThumb ?? "",
                        prepTime: 45,
                        difficulty: "Hard"
                    )) {
                        RecipeCard(
                            title: meal.strMeal ?? "Unknown Recipe",
                            imageURL: meal.strMealThumb ?? "",
                            time: "45m",
                            difficulty: "Hard",
                            matchPercentage: nil,
                            recipe: nil
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
}
                               

// MARK: - Reusable Section Header
struct SectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon).foregroundColor(iconColor)
                    Text(title).font(.title3).fontWeight(.bold)
                }
                Text(subtitle).font(.caption).foregroundColor(.gray)
            }
            Spacer()
//            Button(action: {}) {
//                Text("See All").font(.subheadline).fontWeight(.semibold).foregroundColor(.pink)
//            }
//            .padding(.top, 2)
        }
        .padding(.horizontal)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
