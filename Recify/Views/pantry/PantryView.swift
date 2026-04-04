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
    @State private var isLoading : Bool = true
    
    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    var filteredIngredients: [Ingredients] {
        firebaseManager.ingredients.filter { ingredient in
            let matchesSearch = ingredientsSearch.isEmpty ||
            ingredient.name.localizedCaseInsensitiveContains(ingredientsSearch)
            
            let matchesCategory = selectedFilter == .all ||
            ingredient.category == selectedFilter
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40)
                    .foregroundColor(.blue.opacity(0.15))
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("Pantry").hidden() //has to put this here cuz if i deleted the searrch button will go ramdoly go up so "hidden" until now i think would be an option
                            .bold()
                            .font(.title)
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 30)
                    
                    HStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .overlay {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)
                                        .padding(.leading)
                                    TextField("Search your ingredients...", text: $ingredientsSearch)
                                        .foregroundStyle(.black)
                                }
                            }
                        
                        NavigationLink(destination: AddIngredientView()) {
                            Circle()
                                .shadow(color: .pink.opacity(0.3), radius: 3, y: 2)
                                .foregroundColor(.pink)
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.white)
                                        .font(.title2)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            
            VStack {
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
                
                
                List {
                    if firebaseManager.isLoading && firebaseManager.ingredients.isEmpty {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else if filteredIngredients.isEmpty {
                        Text("Tap the + to add ingredients to your pantry.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .italic()
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(filteredIngredients) { ingredient in
                            IngredientPantryView(ingredient: ingredient)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteIngredient(ingredient)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        }
                        
                        if firebaseManager.canLoadMore {
                            ProgressView()
                                .onAppear {
                                    firebaseManager.fetchIngredients()
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onAppear {
                    firebaseManager.refreshData()
                }
                
                
            }
        }
        .background(Color.pink.opacity(0.05))
        .ignoresSafeArea()
        .padding(.init(top: 0, leading: 0, bottom: 5, trailing: 0))
        .navigationTitle("Pantry")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //the current user specific pantry.
            isLoading = true
            firebaseManager.refreshData()
        }
        .onReceive(firebaseManager.$ingredients) { newIngredients in
            isLoading = false
        }
    }
    
    
    func deleteIngredient(_ ingredient: Ingredients) {
        firebaseManager.deleteIngredient(ingredient)
    }
    
}

#Preview {
    PantryView()
}
