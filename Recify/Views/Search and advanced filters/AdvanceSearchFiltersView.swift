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
    
    @State private var matchPantry : Bool = false
        
    @State private var selectedRestrictions: Set<DietaryRestriction> = []


    var body: some View {
        ZStack{
            Color.purple.opacity(0.04).ignoresSafeArea()
            
            VStack(alignment: .leading){
                
                headerSearchSection.padding(.horizontal)
                
                
                Text("Cooking Time")
                    .bold()
                    .font(.title3)
                
                
                ScrollView(.horizontal, showsIndicators: false){ //time filters
                    HStack{
                        
                        Button {
                            selectedCookTime  = .under15
                        } label: {
                            cookTimeView(title: "Under 15 mins", subTitle: "Super quick", icon:  "bolt.fill", isSelected: selectedCookTime == .under15)

                        }
                        
                        Button {
                            selectedCookTime  = .between15And30
                        } label: {
                            cookTimeView(title: "15-30 mins", subTitle: "Everyday meals", icon:  "fork.knife.circle", isSelected: selectedCookTime == .between15And30)

                        }
                        
                        Button {
                            selectedCookTime  = .over30
                        } label: {
                            cookTimeView(title: "Over 30 mins", subTitle: "More involved cooking", icon:  "clock.fill", isSelected: selectedCookTime == .over30)

                        }
                        
                    }
                }
                
                
                RoundedRectangle(cornerRadius: 10) //match pantry
                    .frame(height: 80)
                    .foregroundStyle(.blue.opacity(0.07))
                    .overlay {
                        HStack{
                            
                            Image(systemName: "refrigerator.fill")
                                .font(.title)
                                .foregroundStyle(.pink)
                                .frame(width: 45, height: 45)
                                .background(Color.white).clipShape(.rect(cornerRadius: 8))
                            VStack{
                                Text("Matching my Pantry")
                                    .bold()
                                Text("Use items you already have")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle(isOn: $matchPantry) {}
                                .frame(width: 50, height: 50)
                                .tint(.pink)
                                .padding()
                                .onTapGesture {
                                    matchPantry.toggle()
                                }
                            
                        }.padding()
                    }
                
                Text("Dietary Restrictions")
                    .bold()
                    .font(.title3)
                    .padding(.top)

                ScrollView(.vertical, showsIndicators: false){
                    ForEach(DietaryRestriction.allCases, id: \.self){ res in
                        
                        HStack{
                            if (res == .vegan){
                                dietImage(icon: "leaf.fill", iconColor: .orange)
                                Text("\(DietaryRestriction.vegan.rawValue)")
                            }
                            else if(res == .dairyFree ) {
                                dietImage(icon: "drop.fill", iconColor: .blue)
                                Text("\(DietaryRestriction.dairyFree.rawValue)")
                            }
                            else if(res == .vegetarian ) {
                                dietImage(icon: "leaf", iconColor: .pink)
                                Text("\(DietaryRestriction.vegetarian.rawValue)")
                            }
                            else if(res == .nutFree ) {
                                dietImage(icon: "cross.circle", iconColor: .brown)
                                Text("\(DietaryRestriction.nutFree.rawValue)")
                            }
                            else if(res == .keto ) {
                                dietImage(icon: "flame.fill", iconColor: .red)
                                Text("\(DietaryRestriction.keto.rawValue)")
                            }
                            else if(res == .glutenFree ) {
                                dietImage(icon: "takeoutbag.and.cup.and.straw.fill", iconColor: .yellow)
                                Text("\(DietaryRestriction.glutenFree.rawValue)")
                            }
                            
                            Spacer()
                            
                            Button {
                                if selectedRestrictions.contains(res) {
                                    selectedRestrictions.remove(res)
                                } else {
                                    selectedRestrictions.insert(res)
                                }
                            } label: {
                                Image(systemName: selectedRestrictions.contains(res) ? "checkmark.square.fill" : "square")
                            }
                            
                        }
                    }.frame(height: 400)
                    
                }.padding(.horizontal) //TODO: remove random enptyr space on top (alexanne) low priority
                
                HStack{
                    Spacer()
                    
                    
                    NavigationLink(destination: SearchResults(oldSearch: searchedIngredient)) {
                        Label("Show Results", systemImage: "chevron.right")
                            .font(.title3)
                            .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                    }.buttonStyle(.bordered)
                        .tint(.pink)
                        .disabled(searchedIngredient.isEmpty) //TODO: add the others to disable the buttons after annabella finsh making the page work
                    Spacer()
                    
                    
                    
//                    Button {
//                        //TODO: TAKE ALL THE filters and search recipes
//                    } label: {
//                        Label("Show Results", systemImage: "chevron.right")
//                            .font(.title3)
//                            .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
//                    }.buttonStyle(.bordered)
//                        .tint(.pink)
//                        .disabled(searchedIngredient.isEmpty) //TODO: add the others to the diables
//                    Spacer()
                }
                
            }
            .padding()
            .navigationTitle("Search & Filters")
            .navigationBarTitleDisplayMode(.inline) //it was really big and ugly so i had to put this
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset"){
                        searchedIngredient = ""
                        selectedCookTime = nil  //this dosnt work
                        matchPantry = false
                        selectedRestrictions = []
                    }.tint(.pink)
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
                }.background(Color.white).clipShape(.rect(cornerRadius: 15)) //i clip the shape to make the background corners rounded liek the rounded rectangle so the whtie dosnt show but it makes the line wieght look skinny but wtv
            
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


#Preview {
    AdvanceSearchFiltersView()
}
