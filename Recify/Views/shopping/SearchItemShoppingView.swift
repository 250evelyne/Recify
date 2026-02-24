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
        VStack(alignment: .leading){
            headerSearchSection.padding(.horizontal)
            
            
                Text("SUGGESTIONS")
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                
            ScrollView(.vertical, showsIndicators: false) {
                if viewModel.isLoading {
                    ProgressView()
                }
                else if !searchedIngredient.isEmpty && viewModel.ingredients.isEmpty {
                    Text("No ingredients found")
                        .foregroundStyle(.gray).padding()
                }
                else{
                    ForEach (viewModel.ingredients, id: \.id) { ingredient in
                        addItemShoppingList(ingredient: ingredient)
                    }
                }
                
            }
            

        }.navigationTitle("Shopping List")
        
        Spacer()
    }
    
    
    private var headerSearchSection: some View {
        VStack {
                        
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue, lineWidth: 2)
                .frame(width: 350, height: 50)
                .foregroundStyle(.white)
                .overlay {
                    HStack {
                        Button {
                            Task{ //see if this works
                                await viewModel.searchIngredients(query: searchedIngredient)
                            }
                        } label: {
                            Image(systemName: "magnifyingglass") //add functionality to this
                                .foregroundStyle(.blue)
                                .padding(.leading)
                            
                        }

                        
                        
                        TextField("Search your ingredients...", text: $searchedIngredient)
                            .foregroundStyle(.black)
                            .onSubmit {
                                Task {
                                    await viewModel.searchIngredients(query: searchedIngredient)
                                }
                            }
                    }
                }.shadow(color: .blue.opacity(0.2), radius: 5)
                .padding(.bottom)
        }
    }
}

#Preview {
    SearchItemShoppingView()
}
