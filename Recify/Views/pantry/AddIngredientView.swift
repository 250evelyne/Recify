//
//  AddIngredientView.swift
//  Recify
//
//  Created by netblen on 2026-02-07.
//

import SwiftUI

struct AddIngredientView: View {
    @StateObject private var viewModel = IngredientViewModel()
    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    @State private var searchedIngredient: String = ""
    @State private var selectedFilter: Filters = .all
    
    @State private var selectedIngredients: [Ingredients] = []
    
    var body: some View {
        VStack(alignment: .center){
            headerSearchSection
            
            VStack(alignment: .leading, spacing: 20){
                filterSection
                
                Text(searchedIngredient.isEmpty ? (selectedFilter == .all ? "SUGGESTED ITEMS" : "\(selectedFilter.rawValue.uppercased()) ITEMS") : "SEARCH RESULTS")
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
        //this ensures the view loads items immediately when it appears
        .onAppear {
            if viewModel.pagedIngredients.isEmpty {
                Task {
                    await viewModel.searchIngredients(query: "")
                }
            }
        }
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
                        viewModel.filterByCategory(filter: filter)
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
            LazyVStack {
                //Show existing pantry items (top 5)
                //this helps users see what they already have
                if searchedIngredient.isEmpty && selectedFilter == .all {
                    
                    ForEach(firebaseManager.ingredients.prefix(5), id: \.name) { item in
                        IngredientsView(ingredient: item)
                    }
                    
                    Divider().padding(.vertical)
                }
          
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
    
    
    private var actionButtonSection: some View {
        HStack {
            Spacer()
            Button {
                for item in selectedIngredients.filter({ ($0.quantity ?? 0) > 0 }) {
                    firebaseManager.addIngredient(
                        name: item.name,
                        imageUrl: item.imageUrl,
                        category: item.category ?? .other,
                        quantity: item.quantity ?? 1,
                        unit: item.unit ?? .pcs
                    )
                }
                selectedIngredients.removeAll()
                searchedIngredient = ""
            } label: {
                Label("Add to Pantry", systemImage: "basket.fill")
                    .font(.title3)
                    .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
            }
            .buttonStyle(.bordered)
            .tint(.pink)
            .disabled(selectedIngredients.isEmpty || !selectedIngredients.contains(where: { ($0.quantity ?? 0) > 0 }))
            
            Spacer()
        }
    }
}

#Preview {
    AddIngredientView()
}
