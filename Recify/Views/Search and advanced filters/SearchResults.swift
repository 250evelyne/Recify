//
//  SearchResults.swift
//  Recify
//
//  Created by Macbook on 2026-03-08.
//

import SwiftUI

struct SearchResults: View {
    @State var oldSearch : String //get the search sent form the other page
    @State private var searchedRecipe: String = ""
    @StateObject private var viewModel = IngredientViewModel()
    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    
    var body: some View {
        /*
        let filteredRecipes = firebaseManager.recipes.filter {
            $0.title.lowercased().contains(oldSearch.lowercased())
        }
        
        VStack{
            
            Divider().foregroundStyle(.gray.opacity(0.02))//check to see if its actually super light
            
            headerSearchSection.padding()
            
            //see if i wanna add the filters here too
            VStack(alignment: .leading){
                HStack{
                    Text("Results for '\(oldSearch)'")
                        .bold()
                        .font(.title3)
                    Spacer()
                    NavigationLink {
                        AdvanceSearchFiltersView()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.pink)
                            .frame(width: 44, height: 44)
                    }
                    
                }.padding(.horizontal)
                
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(filteredRecipes) { recipe in
                        searchResultCard(
                            title: recipe.title,
                            imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
                            time: recipe.timeMinutes,
                            difficulty: recipe.dificulty?.rawValue ?? "Unknown"
                        )
                    }
                }.onAppear {
                    firebaseManager.fetchRecipes(searchQuery: oldSearch)
                }
                Spacer()
            }.background(Color.blue.opacity(0.08))
            
        }.background(Color.white.opacity(0.04))
            .navigationTitle("Results")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle") //TODO: make user profile image
                    }
                }
            }*/
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
                            Task { await viewModel.searchIngredients(query: searchedRecipe) }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                                .padding(.leading)
                        }
                        
                        TextField("Search recipies...", text: $searchedRecipe)
                            .foregroundColor(.black)
                            .onSubmit {
                                Task { await viewModel.searchIngredients(query: searchedRecipe) }
                            }
                    }
                )
                .shadow(color: Color.blue.opacity(0.2), radius: 5)
                .padding(.bottom)
        }
    }

}

#Preview {
    SearchResults(oldSearch: "Pancakes")
}
