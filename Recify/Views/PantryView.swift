//
//  PantryView.swift
//  Recify
//
//  Created by Macbook on 2026-02-06.
//

import SwiftUI

struct PantryView: View {
    
    @State private var ingredientsSearch : String = ""
    @State private var selectedFilter : Filters = .all
    
    
    var filteredIngredients: [Ingredients] {
        firebaseManager.ingredients.filter { ingredient in
            let matchesSearch = ingredientsSearch.isEmpty ||
            ingredient.name.localizedCaseInsensitiveContains(ingredientsSearch)
            
            let matchesCategory = selectedFilter == .all ||
            ingredient.category == selectedFilter
            
            return matchesSearch && matchesCategory
        }
    }
    
    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40)
                    .foregroundColor(.blue.opacity(0.15))
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .overlay {
                        VStack {
                            HStack {
                                Text("Pantry")
                                    .bold()
                                    .font(.title)
                                
                                
                                
                                
                                Spacer()
                                Circle()
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Image("onBordingPageImage")
                                            .resizable()
                                            .clipShape(.circle)
                                            .frame(width: 45, height: 45)
                                    }
                            }.padding(.init(top: 70, leading: 30, bottom: 10, trailing: 30))
                            
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 350, height: 50)
                                .foregroundStyle(.white)
                                .overlay {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundStyle(.secondary)
                                            .padding(.leading)
                                        TextField("Search your ingredients...", text: $ingredientsSearch)
                                            .foregroundStyle(.black)
                                    }
                                }.padding()
                        }
                    }
                
                VStack {
                    // Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Filters.allCases) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    floatingButtonLabel(title: filter.rawValue, image: filter.icon, isSelected: selectedFilter == filter)
                                }
                            }
                        }
                    }.padding(.leading)
                    
                    HStack {
                        Text("Your Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding()
                    
                    ScrollView(.vertical, showsIndicators: false) {

                        ForEach(filteredIngredients) { ingredient in
                            IngredientPantryView(ingredient: ingredient)
                        }
                    }
                    .padding(.horizontal)
                    .overlay {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Circle()
                                    .shadow(color: .pink, radius: 3, y: 2)
                                    .foregroundColor(.pink)
                                    .frame(width: 60, height: 60)
                                    .overlay {
                                        
                                        NavigationLink(destination: AddIngredientView()) {
                                            
                                            Image(systemName: "plus")
                                                .foregroundStyle(.white)
                                                .font(.title)
                                        }
                                    }
                            }.padding()
                        }.padding()
                    }
                }
            }
            .background(Color.pink.opacity(0.05))
            .ignoresSafeArea()
            .padding(.init(top: 0, leading: 0, bottom: 5, trailing: 0))
        }
    }
}
#Preview {
    PantryView()
}

struct ingredient: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .overlay {
                Image(systemName: "")
            }
    }
}
