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
    @State private var ingredientSelected : Bool = true //the  list of ingredients the users wants to add?? not sure how ima do that, or like for now ima just keep track of the check box
    @State private var quantity : Int = 1 //this start at 1 so users don't add 0 items
    
    @State private var selectedUnits: units = units.pcs
    
    @StateObject private var viewModel = IngredientViewModel()

    @State private var searchedIngredient: String = ""
    
    // Track selected ingredients before adding to pantry
    @State private var selectedIngredients: [Ingredients] = []
    
    var body: some View {
        
        
        if #available(iOS 17.0, *) { ///should prob find another solution to this becuase i thinking nothing will show up if they dont have the correct version, becuase of the fill
            VStack{
                
                
                RoundedRectangle(cornerRadius: 20)
                    .overlay( //need to have the over lay here becuase is dont elt me use the baforegourn color else
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ingredientSelected ? Color.blue : Color.gray.opacity(0.1), lineWidth: ingredientSelected ? 3 : 1)
                    )
                    .foregroundColor(.white)
                    .frame(width: 360, height: ingredientSelected ? 180 : 100)
                    .animation(.easeInOut(duration: 0.4), value: ingredientSelected)
                    .shadow(color: .gray.opacity(0.2), radius: 5)
                    .overlay {
                        VStack{
                            HStack{
                                AsyncImage(url: URL(string: ingredient.imageUrl)){phase in
                                    if let image = phase.image{
                                        image.resizable()
                                            .frame(width: 65, height: 65)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(.green.opacity(0.3))
                                            .frame(width: 65, height: 65)
                                            .overlay {
                                                Image(systemName: ingredient.category?.icon ?? "carrot.fill")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.green)
                                            }
                                        
                                    }
                                }
                                
                                VStack(alignment: .leading){
                                    
                                    Text(ingredient.name)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 20))
                                    
                                    Text(ingredient.category?.rawValue ?? "N/A")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 13))
                                    
                                }.padding(.leading)
                                
                                Spacer()
                                
                                if !ingredientSelected {
                                    Button {
                                        ingredientSelected.toggle() //add the actions for the pink check twhen its clicked
                                        
                                        //if they unselect it, we should probably remove it from the parent list
                                        // but for now, we trigger onSelect when they actually click the "Add" button below
                                    } label: {
                                        
                                        Image(systemName: ingredientSelected ? "checkmark.circle.fill" : "plus")
                                            .foregroundStyle(ingredientSelected ? .pink : .gray)
                                            .font(.title)
                                    }
                                    
                                }else{
                                    //changes to an add so it shows that thiswill be added to this shopping list
                                    
                                    Button("Add") {
                                        ingredientSelected.toggle()
                                        //addIngredient(indridient: Ingredient ) //add the ingredetn to the shopping list for the user with the quanity and the unit they picked
                                        //TODO: add a toast saying that the item was added and then the ingredient should be come smaller again
                                    }
                                    
                                }
                                
                                
                            }.padding()
                            
                            
                            
                            if ingredientSelected {
                                
                                Divider().padding(.horizontal).foregroundStyle(.blue)
                                
                                HStack{
                                    
                                    Text("Set quantity: ")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 13))
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 130, height: 30)
                                        .foregroundStyle(.blue.opacity(0.1))
                                        .overlay {
                                            setQuantity
                                        }
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.gray.opacity(0.1))
                                        .frame(width: 80, height: 50)
                                        .overlay {
                                            
                                            Picker("", selection: $selectedUnits) { //loki really wide and i dont like the look but wtv
                                                ForEach(units.allCases, id: \.self){unit in
                                                    Text(unit.rawValue)
                                                }
                                            }.pickerStyle(.menu)
                                                .tint(.black)
                                            
                                        }
                                }.padding()
                            }
                            
                        }
                        
                    }.padding()
            }.padding(5) ///this padding i put becuase if i dont put space arouf it when it cuts it and takes it to the other view it cuts of the outside of the rame so the stroke gets cut off
                .navigationTitle("Shopping List")
            
        } else {
            // Fallback on earlier versions
            Text(ingredient.name)
        }
        
    }

    
    
    private var setQuantity : some View {
        
        var quantity = 1
        
        return HStack(spacing: 20){
            
            Button {
                if quantity != 0 {
                    quantity -= 1
                }
            } label: {
                
                Image(systemName: "minus")
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            
            Text("\(quantity)")
                .fontWeight(.semibold)
                .font(.system(size: 20))
                .padding(5)
            
            Button {
                quantity += 1
            } label: {
                
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
