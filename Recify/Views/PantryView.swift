//
//  PantryView.swift
//  Recify
//
//  Created by Macbook on 2026-02-06.
//

import SwiftUI

struct PantryView: View {
    
    @State private var ingredientsSearch : String = ""
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

    @StateObject var firebaseManager = FirebaseViewModel.shared
    
    var body: some View {
        VStack{
            
            UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40)
                .foregroundColor(.blue.opacity(0.15))
                .frame(maxWidth: .infinity, maxHeight: 220)
                .overlay{
                    VStack{
                        HStack{
                            //he navigation to go back should go shwere fix that later
                            Text("Pantry")
                                .bold()
                                .font(.title)
                            
                            Spacer()
                            
                            Circle()
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image("onBordingPageImage")  //change to user pfp
                                        .resizable()
                                        .clipShape(.circle)
                                        .frame(width: 45, height: 45)
                                }
                            
                        }.padding(.init(top: 70, leading: 30, bottom: 10, trailing: 30))
                        
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 350, height: 50)
                            .foregroundStyle(.white)
                            .overlay {
                                HStack{
                                    Image(systemName: "magnifyingglass") //add functionality to this
                                        .foregroundStyle(.secondary)
                                        .padding(.leading)
                                    
                                    TextField("Search your ingredients...", text: $ingredientsSearch) //like once the user licks enter idk
                                        .foregroundStyle(.black)
                                }
                            }.padding()
                        
                    }
                }
                
            
            VStack{
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(Filters.allCases){
                            filter in
                            
                            Button {
                                selectedFilter = filter
                            } label: {
                                floatingButtonLabel(title: filter.rawValue, image: filter.icon, isSelected: selectedFilter == filter)
                            }
                            
                        }
                    }
                }.padding(.leading)
                
                HStack{
                    Text("Your Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }.padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    //fetch all the users ingredients

                    ForEach(firebaseManager.ingredients){ ingredient in // MARK: this where im getting the ingredients from the ffirebase
                        IngredientPantryView(ingredient: ingredient) ///check it is is actually using the ingredient that i pushed not just a sample one?
                    }.onAppear{
                        if !firebaseManager.ingredients.isEmpty {
                            Task{
                                firebaseManager.fetchIngredients()
                            }
                        }
                    }
                    
                }.padding(.horizontal)
                    .overlay {
                        VStack{
                            Spacer()
                            
                            HStack{
                                Spacer()
                                Circle()
                                    .shadow(color: .pink, radius: 3, y: 2)
                                    .foregroundColor(.pink)
                                    .frame(width: 60, height: 60)
                                    .overlay {
                                        NavigationLink(destination: AddIngredientView()) { ///maek this goes to the right page when we add the navigatoin bar  so i can open the party
                                            Image(systemName: "plus")
                                                .foregroundStyle(.white)
                                                .font(.title)
                                                
                                        }
                                    }
                            }.padding()
                        }.padding()
                    }
                
            }
        
        }.background(Color.pink.opacity(0.05))
        .ignoresSafeArea()
    }
}






#Preview {
    PantryView()
}

struct ingredient: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .overlay {
                Image(systemName: "")
            }
    }
}




