//
//  AddIngredient.swift
//  Recify
//
//  Created by Macbook on 2026-03-27.
//

import SwiftUI

struct AddIngredient: View {
    var onAdd: ([Ingredients]) -> Void = { _ in }


    //@State private var selectedIngredient : Ingredients?
    @StateObject private var viewModel = IngredientViewModel()
    
    @State private var searchedIngredient: String = ""
    @State private var selectedIngredients: [Ingredients] = []

    @State private var quantity : Int = 1
    @State private var selectedUnits: units = units.pcs
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            VStack{
                
                headerSearchSection
                
                ingredientsListSection
                                
                Button {
                    onAdd(selectedIngredients)
                    print("selected ingredients \(selectedIngredients)")
                    dismiss()
                } label: {
                    Label("Add to Recipe", systemImage: "plus.circle.fill")
                        .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                }.font(.title3)
                    .disabled((selectedIngredients.isEmpty))
                    .buttonStyle(.bordered)
                    .tint(.pink)
                
//                NavigationLink(destination: addNewRecipe(ingredients: selectedIngredients)) {
//                    
//                }
                
            }.navigationTitle("Add Ingredient")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }

                    }
                }
        }//nav end
    }
    
    private var headerSearchSection: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 350, height: 50)
                .foregroundStyle(.white)
                .overlay {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .padding(.leading)
                        
                        TextField("Search your ingredients...", text: $searchedIngredient)
                            .foregroundStyle(.black)
                            .onSubmit {
                                Task {
                                    await viewModel.searchIngredients(query: searchedIngredient)
                                }
                            }
                    }
                }
                .shadow(color: .gray.opacity(0.2), radius: 5)
                .padding(.bottom)
        }
    }
    
    
    private var ingredientsListSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                
          
                ForEach(viewModel.pagedIngredients, id: \.name) { ingredient in
                    IngredientsView(ingredient: ingredient) { selectedItem in
                        if let index = selectedIngredients.firstIndex(where: { $0.name == selectedItem.name }) {
                            selectedIngredients[index] = selectedItem
                        } else {
                            selectedIngredients.append(selectedItem)
                        }
                    }
                }
                
                if !viewModel.pagedIngredients.isEmpty {
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.searchIngredients(query: searchedIngredient)
                            }
                        }
                }
            }
        }
    }
    
}


#Preview {
    AddIngredient()
}
