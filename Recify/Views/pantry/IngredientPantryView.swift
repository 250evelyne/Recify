//
//  IngredientPantryView.swift
//  Recify
//
//  Created by Macbook on 2026-02-07.
//

import SwiftUI

struct IngredientPantryView: View {
    
    var ingredient : Ingredients
    @StateObject private var firebaseVM = FirebaseViewModel.shared
    
    var body: some View {
        VStack{
            
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 360, height: 100)
                .foregroundColor(.white)
                //.shadow(radius: 5) //just so i can see with the white background
                .overlay {
                    HStack{
                        AsyncImage(url: URL(string: ingredient.imageUrl)) { image in
                            image.resizable().scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 65, height: 65)

                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.orange.opacity(0.2))
                                .frame(width: 65, height: 65)
                                .overlay {
                                    Image(systemName: ingredient.category?.icon ?? "carrot.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.orange)
                                    
                                }
                        }
                        
                        VStack(alignment: .leading){
                            Text(ingredient.name)
                                .fontWeight(.semibold)
                            Text("\(ingredient.quantity ?? 0) \(ingredient.unit?.rawValue ?? "N/A")").foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button {
                            firebaseVM.updateQuantity(ingredient: ingredient, change: -1)
                            
                            if ingredient.quantity != 0 {
                                
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.pink.opacity(0.2))
                                .overlay {
                                    Image(systemName: "minus")
                                        .foregroundColor(.pink)
                                        .fontWeight(.semibold)
                                        .font(.title3)
                                }
                        }
                        
                        Text("\(ingredient.quantity ?? 0)")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .padding(5)
                        
                        Button {
                            
                            firebaseVM.updateQuantity(ingredient: ingredient, change: 1)
                            //ingredient.quantity += 1
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.pink)
                                .overlay {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .font(.title3)
                                }
                        }
                    }.padding(.horizontal)
                }
        }
        
    }
}

#Preview {
    IngredientPantryView(ingredient: Ingredients(id: "1", name: "Apple", quantity: 4, unit: units.pcs, imageUrl: "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg", category: Filters.vegetables))
}
