//
//  SearchItemShoppingView.swift
//  Recify
//
//  Created by Macbook on 2026-02-23.
//

import SwiftUI

struct SearchItemShoppingView: View {
    @StateObject private var viewModel = IngredientViewModel()
    @State private var searchedIngredient: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            headerSearchSection
                .padding(.horizontal)
            
            Text("SUGGESTIONS")
                .foregroundStyle(.gray)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                if viewModel.isLoading && viewModel.pagedIngredients.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    LazyVStack {
                        
                        ForEach(viewModel.pagedIngredients, id: \.name) { ingredient in
                            addItemShoppingList(ingredient: ingredient)
                                .onAppear {
                                    if ingredient.name == viewModel.pagedIngredients.last?.name {
                                        viewModel.loadNextPage()
                                    }
                                }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("Shopping List")
        .onAppear {
            //this will fetch the initial items when view opens, just like AddIngredientView
            if viewModel.pagedIngredients.isEmpty {
                Task {
                    await viewModel.searchIngredients(query: "")
                }
            }
        }
    }
    
    var headerSearchSection: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue, lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .frame(height: 50)
                .overlay(
                    HStack {
                        Button {
                            Task { await viewModel.searchIngredients(query: searchedIngredient) }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                                .padding(.leading)
                        }
                        
                        TextField("Search your ingredients...", text: $searchedIngredient)
                            .foregroundColor(.black)
                            .onSubmit {
                                Task { await viewModel.searchIngredients(query: searchedIngredient) }
                            }
                    }
                )
                .shadow(color: Color.blue.opacity(0.2), radius: 5)
                .padding(.bottom)
        }
    }
}

#Preview {
    SearchItemShoppingView()
}
