//
//  AddIngredientView.swift
//  Recify
//
//  Created by netblen on 2026-02-07.
//

import SwiftUI

struct AddIngredientView: View {
    @StateObject private var viewModel = IngredientViewModel()
    // Need a reference to the shared Firebase manager to save items
    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    @State private var searchedIngredient: String = ""
    @State private var selectedFilter : Filters = .all
    
    // Track selected ingredients before adding to pantry
    @State private var selectedIngredients: [Ingredients] = []
    
    var body: some View {
        VStack(alignment: .center){
            headerSearchSection // Broken up into a sub-view for the compiler
            
            VStack(alignment: .leading, spacing: 20){
                
                filterSection // Extracted to help compiler
                
                Text("SUGGESTED ITEMS") // now pulling from the actual database
                    .bold()
                    .font(.system(size: 15))
                    .foregroundColor(.gray.opacity(0.8))
                
                ingredientsListSection // Extracted to help compiler
                
                actionButtonSection // Extracted to help compiler
                
            }.padding()
                .background(.blue.opacity(0.1))
        }
    }
    
    // Extracted the header to solve the type-checking time limit error
    private var headerSearchSection: some View {
        VStack {
            Text("Add Ingredients")
                .font(.title2)
                .fontWeight(.semibold)
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 350, height: 50)
                .foregroundStyle(.white)
                .overlay {
                    HStack {
                        Image(systemName: "magnifyingglass") //add functionality to this
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
                }.shadow(color: .gray.opacity(0.2), radius: 5)
                .padding()
        }
    }
    
    // Extracted Filter bar
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(Filters.allCases){ filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 15))
                            .padding()
                            .background( selectedFilter == filter ? .pink : .white)
                            .foregroundColor(selectedFilter == filter ? .white : .black)
                            .cornerRadius(25)
                    }
                }
            }
        }
    }
    
    // Extracted ScrollView with ingredients
    private var ingredientsListSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            // Display existing ingredients from Firebase as suggestions
            ForEach(firebaseManager.ingredients.prefix(5)) { ingredient in
                IngredientsView(ingredient: ingredient)
            }
            
            Divider()
                .padding(.vertical)
            
            // Results from the API search
            ForEach(viewModel.ingredients) { ingredient in
                IngredientsView(ingredient: ingredient) { selectedItem in
                    if let index = selectedIngredients.firstIndex(where: { $0.name == selectedItem.name }) {
                        selectedIngredients[index] = selectedItem
                    } else {
                        selectedIngredients.append(selectedItem)
                    }
                }
            }
        }
    }
    
    private var actionButtonSection: some View {
        HStack{
            Spacer()
            
            Button { ///need to remeber to make the button turn off if no items are selected
                //save/add ingreditants
                for item in selectedIngredients {
                    firebaseManager.addIngredient(
                        name: item.name,
                        imageUrl: item.imageUrl,
                        category: item.category ?? .vegetables,
                        quantity: item.quantity ?? 1,
                        unit: item.unit ?? .pcs
                    )
                }
                // Clear selection after adding
                selectedIngredients.removeAll()
                searchedIngredient = "" // Clear search bar after adding
                viewModel.ingredients.removeAll() // Clear search results after adding
            } label: {
                Label("Add to Pantry", systemImage: "basket.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.init(top: 15, leading: 70, bottom: 15, trailing: 70))
            }.buttonStyle(.bordered)
                .tint(.pink)
                .disabled(selectedIngredients.isEmpty) // Turn off if no items selected
            
            Spacer()
        }
    }
    
    
    //filter doies not work at the moment (not sure at all so test it plss)
    
}

#Preview {
    AddIngredientView()
}
