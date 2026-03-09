//
//  HomeView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText: String = ""
    
    let pantryMatchRecipes = [
        (title: "Zesty Avocado Quinoa", image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400", time: "25m", difficulty: "Easy", rating: 4.7, match: 90),
        (title: "Harissa Chickpea Bowl", image: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400", time: "30m", difficulty: "Medium", rating: 4.8, match: 85)
    ]
    
    let trendingRecipes = [
        (title: "Garlic Herb Seared Steak", image: "https://images.unsplash.com/photo-1546833998-877b37c2e5c6?w=400", time: "25m", difficulty: "Easy", rating: 4.7),
        (title: "Neapolitan Basil Pizza", image: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400", time: "50m", difficulty: "Medium", rating: 4.7),
        (title: "Yakitori Style Skewers", image: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400", time: "30m", difficulty: "Medium", rating: 4.3),
        (title: "Buttermilk Berry Stack", image: "https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=400", time: "20m", difficulty: "Easy", rating: 4.5)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search by ingredients (e.g., Chicken)", text: $searchText)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        NavigationLink {
                            AdvanceSearchFiltersView()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.pink)
                                .frame(width: 44, height: 44)
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Perfect for your Pantry")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(pantryMatchRecipes, id: \.title) { recipe in
                                    RecipeCard(
                                        title: recipe.title,
                                        imageURL: recipe.image,
                                        time: recipe.time,
                                        difficulty: recipe.difficulty,
                                        rating: recipe.rating,
                                        matchPercentage: recipe.match
                                    )
                                    .frame(width: 180)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.pink)
                            Text("Trending Now")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(trendingRecipes, id: \.title) { recipe in
                                RecipeCard(
                                    title: recipe.title,
                                    imageURL: recipe.image,
                                    time: recipe.time,
                                    difficulty: recipe.difficulty,
                                    rating: recipe.rating,
                                    matchPercentage: nil
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
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
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
