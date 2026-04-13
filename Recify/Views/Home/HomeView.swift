//
//  HomeView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Category Filter Pills
                    categoryFilterSection

                    // MARK: - Search Bar & Filter
                    searchBarSection
                    
                    // MARK: - Category Navigation
                    categoryNavSection

                  
                    
                    // MARK: - Dynamic Content Area
                    if viewModel.isSearching {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    }
                    else if viewModel.hasNoResults {
                        noResultsView
                    }
                    else if !viewModel.searchResults.isEmpty {
                        searchResultsGrid
                    } else {
                        
                        if viewModel.isLoading {
                            ProgressView("Loading Recipes...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        }
                        
                        if !viewModel.pantryMeals.isEmpty {
                            pantryMatchSection
                        }
                        
                        if !viewModel.trendingMeals.isEmpty {
                            trendingSection
                        }
                    }
                    
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.98, blue: 1.0),
                        Color(red: 0.85, green: 0.93, blue: 1.0),
                        Color(red: 1.0, green: 0.90, blue: 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if viewModel.pantryMeals.isEmpty && viewModel.trendingMeals.isEmpty {
                    await viewModel.fetchHomeData()
                }
            }
        }
    }
    
    // MARK: - Extracted Subviews
    
    // Category nav items
    private var categoryNavSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                NavigationLink(destination: ShoppingList()) {
                    CategoryNavItem(icon: "cart.fill", label: "Shopping", color: .green)
                }
                NavigationLink(destination: PantryView()) {
                    CategoryNavItem(icon: "archivebox.fill", label: "Pantry", color: .orange)
                }
                NavigationLink(destination: CalendarView()) {
                    CategoryNavItem(icon: "calendar", label: "Calendar", color: .teal)
                }
              
                NavigationLink(destination: savedCollectionsView()) {
                    CategoryNavItem(icon: "books.vertical.fill", label: "Collections", color: .indigo)
                }
                NavigationLink(destination: CookingStatisticsTabView()) {
                    CategoryNavItem(icon: "chart.bar.fill", label: "Stats", color: .purple)
                }
                
                if #available(iOS 17.0, *) {
                    NavigationLink(destination: GroceryMapsView()) {
                        CategoryNavItem(icon: "map.fill", label: "Map", color: .blue)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Category filter
    private let categories = [
        ("All", "🍽️"),
        ("Chicken", "🍗"),
        ("Beef", "🥩"),
        ("Lamb", "🍖"),
        ("Pork", "🥓"),
        ("Seafood", "🦞"),
        ("Pasta", "🍝"),
        ("Vegetarian", "🥗"),
        ("Vegan", "🌱"),
        ("Dessert", "🍰"),
        ("Breakfast", "🥞"),
        ("Starter", "🥗"),
        ("Side", "🍟"),
        ("Goat", "🐐")
    ]

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.0) { category, emoji in
                    Button {
                        selectedCategory = category
                        Task {
                            await viewModel.fetchByCategory(category)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(emoji)
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(selectedCategory == category ? .bold : .regular)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color.pink : Color.gray.opacity(0.1))
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search recipes (e.g., Chicken)", text: $searchText)
                    .autocapitalization(.none)
                    .onSubmit {
                        Task {
                            await viewModel.searchMeals(query: searchText, filters: SearchFilters())
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
    
    // MARK: - Search Results Grid
    private var searchResultsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Search Results", subtitle: "Found \(viewModel.searchResults.count) recipes", icon: "magnifyingglass", iconColor: .pink)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.offset) { index, recipe in
                    NavigationLink(destination: RecipeInstructionsView(
                        mealId: recipe.id ?? recipe.title,
                        recipeTitle: recipe.title,
                        recipeImage: recipe.imageURL ?? "",
                        prepTime: recipe.prepTime,
                        difficulty: recipe.level,
                        recipe: recipe
                    )) {
                        RecipeCard(
                            title: recipe.title,
                            imageURL: recipe.imageURL ?? "",
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
    
    // MARK: - Pantry Match Section
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
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: selectedCategory == "All" ? "Trending Now" : "\(selectedCategory) Recipes",
                subtitle: selectedCategory == "All" ? "Popular picks for you" : "Filtered by \(selectedCategory)",
                icon: "flame.fill",
                iconColor: .pink
            )
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(viewModel.trendingMeals) { meal in
                    NavigationLink(destination: RecipeInstructionsView(
                        mealId: meal.idMeal,
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

// MARK: - Category Nav Item
struct CategoryNavItem: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(14)
            Text(label)
                .font(.caption2)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
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
        }
        .padding(.horizontal)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
