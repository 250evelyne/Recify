//
//  addItemShoppingList.swift
//  Recify
//
//  Created by Macbook on 2026-02-22.
//

import SwiftUI

struct addItemShoppingList: View {
    
    let ingredient : Ingredients
    
    var onSelect: ((Ingredients) -> Void)? = nil
    
    //manual initializer to handle both the simple call and the trailing closure call
    init(ingredient: Ingredients, onSelect: ((Ingredients) -> Void)? = nil) {
        self.ingredient = ingredient
        self.onSelect = onSelect
    }
    //fyi for later he @state maeks it mutable thats why our toggle wasnt working
    @State private var ingredientSelected : Bool = false
    @State private var quantity : Int = 1 //this start at 1 so users don't add 0 items
    
    @State private var selectedUnits: units = units.pcs
    
    @StateObject private var viewModel = IngredientViewModel()
    
    @State private var searchedIngredient: String = ""
    
    //this track selected ingredients before adding to pantry
    @State private var selectedIngredients: [Ingredients] = []
    
    //toast notification
    @State private var showToast: Bool = false
    
    var body: some View {
        ZStack {
            VStack{
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ingredientSelected ? Color.blue : Color.gray.opacity(0.1), lineWidth: ingredientSelected ? 3 : 1)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .frame(width: 360, height: ingredientSelected ? 180 : 100)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: ingredientSelected)
                    .shadow(color: Color.gray.opacity(0.2), radius: 5)
                    .overlay(
                        VStack{
                            HStack{
                                AsyncImage(url: URL(string: ingredient.imageUrl)){phase in
                                    if let image = phase.image{
                                        image.resizable()
                                            .frame(width: 65, height: 65)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color.green.opacity(0.3))
                                            .frame(width: 65, height: 65)
                                            .overlay(
                                                Image(systemName: ingredient.category?.icon ?? "carrot.fill")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.green)
                                            )
                                    }
                                }
                                
                                VStack(alignment: .leading){
                                    Text(ingredient.name)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 20))
                                    
                                    Text(ingredient.category?.rawValue ?? "N/A")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                }.padding(.leading)
                                
                                Spacer()
                                
                                if !ingredientSelected {
                                    Button(action: {
                                        withAnimation { ingredientSelected.toggle() }
                                    }) {
                                        Image(systemName: "plus")
                                            .foregroundColor(.gray)
                                            .font(.title)
                                    }
                                } else {
                                    Button("Add") {
                                        FirebaseViewModel.shared.addToShoppingList(
                                            name: ingredient.name,
                                            imageUrl: ingredient.imageUrl,
                                            category: ingredient.category ?? .other,
                                            quantity: quantity,
                                            unit: selectedUnits
                                        )
                                        
                                        // Trigger the collapse and toast
                                        withAnimation(.easeInOut) {
                                            ingredientSelected = false // ingredient should be come smaller again
                                            showToast = true // show the toast
                                        }
                                        
                                        // Hide toast after 2 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation { showToast = false }
                                        }
                                    }
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                }
                            }.padding()
                            
                            if ingredientSelected {
                                Divider().padding(.horizontal).background(Color.blue)
                                
                                HStack{
                                    Text("Set quantity: ")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 13))
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 130, height: 30)
                                        .overlay(setQuantity)
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 80, height: 50)
                                        .overlay(
                                            Picker("", selection: $selectedUnits) {
                                                ForEach(units.allCases, id: \.self){unit in
                                                    Text(unit.rawValue).tag(unit)
                                                }
                                            }
                                                .pickerStyle(MenuPickerStyle())
                                                .tint(.black)
                                        )
                                }.padding()
                            }
                        }
                    )
            }
            .padding(5)
            
            //toast TODO??
            if showToast {
                VStack {
                    Spacer()
                    Text("Added \(ingredient.name) to Shopping List!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Capsule().fill(Color.black.opacity(0.8)))
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Shopping List")
    }
    
    private var setQuantity : some View {
        HStack(spacing: 20){
            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                Image(systemName: "minus")
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            
            Text("\(quantity)")
                .fontWeight(.semibold)
                .font(.system(size: 20))
                .padding(5)
            
            Button(action: { quantity += 1 }) {
                Image(systemName: "plus")
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    addItemShoppingList(ingredient: Ingredients(id: "1", name: "Carrot", quantity: 5, unit: .cups, imageUrl: "https://spoonacular.com/cdn/ingredients_100x100/carrot.png", category: .vegetables))
}
