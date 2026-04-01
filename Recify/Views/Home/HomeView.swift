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
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search recipes (e.g., Chicken)", text: $searchText)
                                .autocapitalization(.none)
                                .onSubmit {
                                    Task {
                                        await viewModel.searchMeals(query: searchText)
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
                    
                    
                    // MARK: - Dynamic Content Area
                    // If searching, show the search loader
                    if viewModel.isSearching {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                        
                        // If we have search results, ONLY show the search results grid
                    }
                    else if viewModel.hasNoResults {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.bottom, 8)
                            
                            Text("No results found")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("We couldn't find any recipes for \"\(searchText)\". Try searching for a different ingredient.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                    }
                    else if !viewModel.searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(
                                title: "Search Results",
                                subtitle: "Found \(viewModel.searchResults.count) recipes",
                                icon: "magnifyingglass",
                                iconColor: .pink
                            )
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                ForEach(viewModel.searchResults) { meal in
                                    NavigationLink(destination: RecipeInstructionsView(
                                        mealId: meal.idMeal,
                                        recipeTitle: meal.strMeal,
                                        recipeImage: meal.strMealThumb
                                    )) {
                                        RecipeCard(
                                            title: meal.strMeal,
                                            imageURL: meal.strMealThumb,
                                            time: "30m",
                                            difficulty: "Medium",
                                            rating: 4.5,
                                            matchPercentage: nil
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                    } else {
                        
                        //Loading thing
                        if viewModel.isLoading {
                            ProgressView("Loading Recipes...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        }
                        
                        // Pantry Match Section
                        if !viewModel.pantryMeals.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(
                                    title: "Perfect for your Pantry",
                                    subtitle: viewModel.pantrySubtitle,
                                    icon: "sparkles",
                                    iconColor: .yellow
                                )
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.pantryMeals) { meal in
                                            NavigationLink(destination: RecipeInstructionsView(
                                                mealId: meal.idMeal,
                                                recipeTitle: meal.strMeal,
                                                recipeImage: meal.strMealThumb
                                            )) {
                                                RecipeCard(
                                                    title: meal.strMeal,
                                                    imageURL: meal.strMealThumb,
                                                    time: "30m",
                                                    difficulty: "Medium",
                                                    rating: 4.5,
                                                    matchPercentage: 85
                                                )
                                                .frame(width: 160)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Trending Now Section
                        if !viewModel.trendingMeals.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(
                                    title: "Trending Now",
                                    subtitle: "Popular picks for you",
                                    icon: "flame.fill",
                                    iconColor: .pink
                                )
                                
                                LazyVGrid(
                                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                                    spacing: 16
                                ) {
                                    ForEach(viewModel.trendingMeals) { meal in
                                        NavigationLink(destination: RecipeInstructionsView(
                                            mealId: meal.idMeal,
                                            recipeTitle: meal.strMeal,
                                            recipeImage: meal.strMealThumb
                                        )) {
                                            RecipeCard(
                                                title: meal.strMeal,
                                                imageURL: meal.strMealThumb,
                                                time: "45m",
                                                difficulty: "Hard",
                                                rating: 4.8,
                                                matchPercentage: nil
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
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("See All")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
