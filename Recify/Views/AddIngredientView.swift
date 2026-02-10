//
//  AddIngredientView.swift
//  Recify
//
//  Created by Macbook on 2026-02-07.
//

import SwiftUI

struct AddIngredientView: View {
    
    @State private var searchedIngredient: String = ""
    @State private var selectedFilter : Filters = .all

    let sampleIngredients = [
        Ingredients(
            id: "1",
            name: "Carrot",
            quantity: 4,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/7/7e/Carrot.jpg",
            category: .vegetables
        ),
        Ingredients(
            id: "2",
            name: "Milk",
            quantity: 1,
            unit: .liters,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/a/a4/Milk_glass.jpg",
            category: .dairy
        ),
        Ingredients(
            id: "3",
            name: "Apple",
            quantity: 6,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg",
            category: .fruits
        ),
        Ingredients(
            id: "4",
            name: "Eggs",
            quantity: 12,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/7/70/Chicken_eggs.jpg",
            category: .dairy
        ),
        Ingredients(
            id: "5",
            name: "Banana",
            quantity: 5,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg",
            category: .fruits
        ),
        Ingredients(
            id: "6",
            name: "Tomato",
            quantity: 8,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/8/88/Tomato_je.jpg",
            category: .vegetables
        ),
        Ingredients(
            id: "7",
            name: "Bread",
            quantity: 2,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/0/05/Bread-2.jpg",
            category: .grains
        ),
        Ingredients(
            id: "8",
            name: "Cheese",
            quantity: 1,
            unit: .grams,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/6/6b/Cheese.jpg",
            category: .dairy
        ),
        Ingredients(
            id: "9",
            name: "Rice",
            quantity: 500,
            unit: .grams,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/6/65/Rice.jpg",
            category: .grains
        ),
        Ingredients(
            id: "10",
            name: "Strawberries",
            quantity: 15,
            unit: .pcs,
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/2/29/PerfectStrawberry.jpg",
            category: .fruits
        )
    ]

    var body: some View {
        VStack(alignment: .center){
            VStack{
                Text("Add Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 350, height: 50)
                    .foregroundStyle(.white)
                    .overlay {
                        HStack{
                            Image(systemName: "magnifyingglass") //add functionality to this
                                .foregroundStyle(.secondary)
                                .padding(.leading)
                            
                            TextField("Search your ingredients...", text: $searchedIngredient) //like once the user licks enter idk
                                .foregroundStyle(.black)
                        }
                    }.shadow(color: .gray.opacity(0.2), radius: 5)
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 20){
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(Filters.allCases){
                            filter in
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
                
                Text("SUGGESTED ITEMS") //for the sugested item ima just forech loop through the first 5 ingreditens in the db
                    .bold()
                    .font(.system(size: 15))
                    .foregroundColor(.gray.opacity(0.8))
                
                ScrollView(.vertical, showsIndicators: false) {
                    //loop threw like 5 ingredients
                    ForEach(sampleIngredients.prefix(5)) { ingredient in
                        IngredientsView(ingredient:  ingredient)
                    }
                    
                }
                
                HStack{
                    Spacer()
                    
                    Button { ///need to remeber to make the button turn off if no items are selected and then turn of if threre are
                        //save/add ingreditants
                    } label: {
                        Label("Add to Pantry", systemImage: "basket.fill")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.init(top: 15, leading: 70, bottom: 15, trailing: 70))
                    }.buttonStyle(.bordered)
                        .tint(.pink)
                        //.shadow(color: .pink, radius: 3, x: 5, y: 5)
                    
                    Spacer()
                }

                
            }.padding()
            .background(.blue.opacity(0.1))
        }
    }
}

#Preview {
    AddIngredientView()
}
