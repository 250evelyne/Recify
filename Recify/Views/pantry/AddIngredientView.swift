//
//  AddIngredientView.swift
//  Recify
//
//  Created by netblen on 2026-02-07.
//

import SwiftUI

struct AddIngredientView: View {
    @StateObject private var viewModel = IngredientViewModel()
    // Reference to the shared Firebase manager to save items
    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    @State private var searchedIngredient: String = ""
    @State private var selectedFilter: Filters = .all
    
    // Track selected ingredients before adding to pantry
    @State private var selectedIngredients: [Ingredients] = []
    
    var body: some View {
        VStack(alignment: .center){
            headerSearchSection
            
            VStack(alignment: .leading, spacing: 20){
                filterSection
                
                Text("SUGGESTED ITEMS")
                    .bold()
                    .font(.system(size: 15))
                    .foregroundColor(.gray.opacity(0.8))
                
                ingredientsListSection
                
                actionButtonSection
                
            }
            .padding()
            .background(Color.blue.opacity(0.1))
        }
        .navigationTitle("Add Ingredients")
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
                            .background(selectedFilter == filter ? Color.pink : Color.white)
                            .foregroundColor(selectedFilter == filter ? .white : .black)
                            .cornerRadius(25)
                    }
                }
            }
        }
    }
    
    
    private var ingredientsListSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            //Show existing pantry items (top 5)
            ForEach(firebaseManager.ingredients.prefix(5)) { item in
                IngredientsView(ingredient: item)
            }
            
            Divider().padding(.vertical)
            
            ForEach(viewModel.pagedIngredients) { ingredient in
                IngredientsView(ingredient: ingredient) { selectedItem in
                    // Logic to update the selection list
                    if let index = selectedIngredients.firstIndex(where: { $0.name == selectedItem.name }) {
                        selectedIngredients[index] = selectedItem
                    } else {
                        selectedIngredients.append(selectedItem)
                    }
                }
                .onAppear {
                    // Trigger pagination when the last item is reached
                    if ingredient.apiId == viewModel.pagedIngredients.last?.apiId {
                        viewModel.loadNextPage()
                    }
                }
            }
        }
    }
    
    private var actionButtonSection: some View {
        HStack{
            Spacer()
            
            Button {
                for item in selectedIngredients {
                    firebaseManager.addIngredient(
                        name: item.name,
                        imageUrl: item.imageUrl,
                        category: item.category ?? .vegetables,
                        quantity: item.quantity ?? 1,
                        unit: item.unit ?? .pcs
                    )
                }
                selectedIngredients.removeAll()
                searchedIngredient = ""
                viewModel.pagedIngredients.removeAll()
            } label: {
                Label("Add to Pantry", systemImage: "basket.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
            }
            .buttonStyle(.bordered)
            .tint(.pink)
            .disabled(selectedIngredients.isEmpty)
            
            Spacer()
        }
    }
}

#Preview {
    AddIngredientView()
}
