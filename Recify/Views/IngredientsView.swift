//
//  IngredientsView.swift
//  Recify
//
//  Created by Macbook on 2026-02-07.
//

import SwiftUI

struct IngredientsView: View {
    
    let ingredient : Ingredients
    
    var onSelect: ((Ingredients) -> Void)? = nil
    
    //manual initializer to handle both the simple call and the trailing closure call
    init(ingredient: Ingredients, onSelect: ((Ingredients) -> Void)? = nil) {
        self.ingredient = ingredient
        self.onSelect = onSelect
    }
    
    //fyi for later he @state maeks it mutable thats why our toggle wasnt working
    @State private var ingredientSelected : Bool = false //the  list of ingredients the users wants to add?? not sure how ima do that, or like for now ima just keep track of the check box
    @State private var quantity : Int = 1 //this start at 1 so users don't add 0 items
    
    @State private var selectedUnits: units = units.pcs
    
    
    var body: some View {
        if #available(iOS 17.0, *) { ///should prob find another solution to this becuase i thinking nothing will show up if they dont have the correct version, becuase of the fill
            RoundedRectangle(cornerRadius: 20)
                .overlay( //need to have the over lay here becuase is dont elt me use the baforegourn color else
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ingredientSelected ? Color.pink : Color.gray.opacity(0.1), lineWidth: ingredientSelected ? 3 : 1)
                )
                .foregroundColor(.white) //switch this back to white at the end
                .frame(width: 360, height: ingredientSelected ? 200 : 100)
                .animation(.easeInOut(duration: 0.4), value: ingredientSelected) ///anaimation kinda ugly might change it later
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
                            
                            Button {
                                ingredientSelected.toggle() //add the actions for the pink check twhen its clicked
                                
                                //if they unselect it, we should probably remove it from the parent list
                                // but for now, we trigger onSelect when they actually click the "Add" button below
                            } label: {
                                Image(systemName: ingredientSelected ? "checkmark.circle.fill" : "plus")
                                    .foregroundStyle(ingredientSelected ? .pink : .gray)
                                    .font(.title)
                            }
                        }
                        
                        if ingredientSelected {
                            
                            Divider()
                            
                            HStack{
                                Text("QUANTITY")
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 13))
                                
                                Spacer()
                                
                                Text("UNIT")
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 13))
                                
                            }.padding(.top)
                            
                            HStack{
                                Button {
                                    if quantity != 0 {
                                        quantity -= 1
                                    }
                                } label: {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        .frame(width: 40)
                                        .foregroundColor(.white)
                                        .overlay {
                                            Image(systemName: "minus")
                                                .foregroundColor(.black.opacity(0.7))
                                                .fontWeight(.semibold)
                                                .font(.title3)
                                        }
                                }
                                
                                Text("\(quantity)")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 20))
                                    .padding(5)
                                
                                Button {
                                    quantity += 1
                                } label: {
                                    Circle()
                                        .frame(width: 40)
                                        .foregroundColor(.pink.opacity(0.2))
                                        .overlay {
                                            Image(systemName: "plus")
                                                .foregroundColor(.pink)
                                                .fontWeight(.semibold)
                                                .font(.title3)
                                        }
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
                            }
                            
                            //confirms the selection with the picked quantity and unit
                            Button {
                                let updatedIngredient = Ingredients(
                                    id: ingredient.id,
                                    name: ingredient.name,
                                    quantity: quantity,
                                    unit: selectedUnits,
                                    imageUrl: ingredient.imageUrl,
                                    category: ingredient.category
                                )
                                onSelect?(updatedIngredient)
                            } label: {
                                Text("Confirm Selection")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.pink)
                            }
                            .padding(.top, 5)
                            
                        }
                        
                    }.padding()
                }.padding(5) ///this padding i put becuase if i dont put space arouf it when it cuts it and takes it to the other view it cuts of the outside of the rame so the stroke gets cut off
        } else {
            // Fallback on earlier versions
            Text(ingredient.name)
        }
        
    }
}

#Preview {
    IngredientsView(ingredient: Ingredients(id: "1", name: "Carrot", quantity: 5, unit: .cups, imageUrl: "https://spoonacular.com/cdn/ingredients_100x100/carrot.png", category: .vegetables))
}
