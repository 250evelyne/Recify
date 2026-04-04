//
//  AdvanceSearchFiltersView.swift
//  Recify
//
//  Created by Macbook on 2026-03-03.
//

import SwiftUI

struct AdvanceSearchFiltersView: View {
    
    @StateObject private var viewModel = IngredientViewModel()
    @State private var searchedIngredient: String = ""
    @State private var selectedCookTime: CookTime?
    @State private var matchPantry: Bool = false
    @State private var selectedRestrictions: Set<DietaryRestriction> = []


    var body: some View {
        ZStack {
            Color.purple.opacity(0.04).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                headerSearchSection.padding(.horizontal)
                
                Text("Cooking Time")
                    .bold()
                    .font(.title3)
                
                cookingTimeScrollView
                
                pantryToggleView
                
                Text("Dietary Restrictions")
                    .bold()
                    .font(.title3)
                    .padding(.top)
                
                dietaryRestrictionsList
                
                Spacer()
                
                resultsButtonSection
                
            }
            .padding()
            .navigationTitle("Search & Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        searchedIngredient = ""
                        selectedCookTime = nil
                        matchPantry = false
                        selectedRestrictions = []
                    }.tint(.pink)
                }
            }
        }
        //Button {
            //                    } label: {
            //                        Label("Show Results", systemImage: "chevron.right")
            //                            .font(.title3)
            //                            .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
            //                    }.buttonStyle(.bordered)
            //                        .tint(.pink)
            //                        .disabled(searchedIngredient.isEmpty)
        
            //                    Spacer()
       // }
        
        
    }
    
    // MARK: - Extracted Sections
    private var cookingTimeScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button {
                    selectedCookTime = (selectedCookTime == .under15) ? nil : .under15
                } label: {
                    cookTimeView(title: "Under 15 mins", subTitle: "Super quick", icon:  "bolt.fill", isSelected: selectedCookTime == .under15)
                }
                
                Button {
                    selectedCookTime = (selectedCookTime == .between15And30) ? nil : .between15And30
                } label: {
                    cookTimeView(title: "15-30 mins", subTitle: "Everyday meals", icon:  "fork.knife.circle", isSelected: selectedCookTime == .between15And30)
                }
                
                Button {
                    selectedCookTime = (selectedCookTime == .over30) ? nil : .over30
                } label: {
                    cookTimeView(title: "Over 30 mins", subTitle: "More involved", icon:  "clock.fill", isSelected: selectedCookTime == .over30)
                }
            }
        }
    }
    
    private var pantryToggleView: some View {
        RoundedRectangle(cornerRadius: 15)
            .frame(height: 90)
            .foregroundStyle(.blue.opacity(0.07))
            .overlay {
                HStack {
                    Image(systemName: "refrigerator.fill")
                        .font(.title2)
                        .foregroundStyle(.pink)
                        .frame(width: 45, height: 45)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading) {
                        Text("Matching my Pantry")
                            .bold()
                        Text("Use items you already have")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Toggle("", isOn: $matchPantry)
                        .labelsHidden()
                }
                .padding()
            }
    }
    
    private var dietaryRestrictionsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(DietaryRestriction.allCases, id: \.self) { res in
                    HStack {
                        getIconForRestriction(res)
                        Text(res.rawValue)
                        Spacer()
                        Button {
                            if selectedRestrictions.contains(res) {
                                selectedRestrictions.remove(res)
                            } else {
                                selectedRestrictions.insert(res)
                            }
                        } label: {
                            Image(systemName: selectedRestrictions.contains(res) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedRestrictions.contains(res) ? .pink : .gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var resultsButtonSection: some View {
        HStack {
            Spacer()
            
            let currentFilters = SearchFilters(
                        cookTime: selectedCookTime,
                        dietaryRestrictions: Array(selectedRestrictions),
                        matchPantry: matchPantry
                    )
            
            let canSearch =
                       !searchedIngredient.isEmpty ||
                       matchPantry ||
                       selectedCookTime != nil ||
                       !selectedRestrictions.isEmpty
            
            
            NavigationLink(destination: SearchResults(query: searchedIngredient, filters: currentFilters)) {
                Label("Show Results", systemImage: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(canSearch ? Color.pink : Color.gray)
                    .cornerRadius(25)
            }
            .disabled(!canSearch)
            
            Spacer()
        }
    }
    
    private var headerSearchSection: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .frame(height: 50)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .padding(.leading)
                    TextField("Search your ingredients...", text: $searchedIngredient)
                        .foregroundColor(.black)
                }
            )
            .padding(.bottom)
    }
}


struct cookTimeView : View {
    var title : String
    var subTitle : String
    var icon : String
    var isSelected : Bool
    
    var body: some View {
        
        VStack{
            
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? .pink : .white, lineWidth: 2)
                .frame(width: 160, height: 80)
                .overlay {
                    HStack{
                        VStack(alignment: .leading){
                            Text(title).foregroundStyle(.black)
                                .fontWeight(.semibold)
                            Text(subTitle)
                                .foregroundStyle(.gray)
                                .font(.caption)
                        }.padding(3)
                        
                        Image(systemName: icon)
                            .foregroundStyle(isSelected ? .pink : .gray)
                    }
                }.background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                ) //i clip the shape to make the background corners rounded liek the rounded rectangle so the whtie dosnt show but it makes the line wieght look skinny but wtv
            //idk if u like this bro -ana
            
        }.padding(3)
    }
}

struct dietImage : View {
    var icon : String
    var iconColor : Color
    var body: some View {
        Image(systemName: icon)
            .font(.title3)
            .foregroundStyle(iconColor)
            .frame(width: 40, height: 40)
            .background(iconColor.opacity(0.1)).clipShape(.circle)
    }
}

func getIconForRestriction(_ res: DietaryRestriction) -> some View {
    switch res {
    case .vegan: return dietImage(icon: "leaf.fill", iconColor: .green)
    case .vegetarian: return dietImage(icon: "leaf", iconColor: .orange)
    case .dairyFree: return dietImage(icon: "drop.fill", iconColor: .blue)
    case .nutFree: return dietImage(icon: "allergens", iconColor: .brown)
    case .glutenFree: return dietImage(icon: "laurel.leading", iconColor: .yellow)
    case .keto: return dietImage(icon: "flame.fill", iconColor: .red)
    default: return dietImage(icon: "info.circle", iconColor: .gray)
    }
}

#Preview {
    AdvanceSearchFiltersView()
}
