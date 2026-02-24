//
//  ShoppingList.swift
//  Recify
//
//  Created by Macbook on 2026-02-21.
//

import SwiftUI

struct ShoppingList: View {
    
    @State private var selectedTab : Int = 0
    @State private var isSelected : Bool = false
    
    var body: some View {
        VStack{
            
            
            HStack{
                Image(systemName: "basket.fill")
                    .foregroundStyle(.blue)
                    .font(.title)
                Text("Shopping List")
                    .bold()
                    .font(.system(size: 25))
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Clear Completed")
                        .foregroundStyle(Color("primaryColor"))
                    //.opacity(0.6)
                        .fontWeight(.semibold)
                }
                
            }.padding(.horizontal)
            
            Divider()
                .overlay(Color.orange.opacity(0.3))
            
            
            HStack{
                
                tabView(index: 0, title: "By Type", selectedTab: $selectedTab)
                tabView(index: 1, title: "By Recipe", selectedTab: $selectedTab)
                Spacer()
            }.padding(.horizontal)
                .padding(.top)
            
            Divider()
                .overlay(Color.orange.opacity(0.3))
            
            //foreach item the user added to thier shopping list
            shopItemView(category: .condiments, title: "ketchup", quantity: 1, unit: .pcs, isSelected: $isSelected)

            Spacer()
            
            HStack{
                Spacer()
                Circle()
                    .shadow(color: .pink, radius: 3, y: 2)
                    .foregroundColor(.pink)
                    .frame(width: 60, height: 60)
                    .overlay {
                        
                        NavigationLink(destination: AddIngredientView()) {
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .font(.title)
                        }
                    }
            }.padding()
        }
        .background(.blue.opacity(0.05))
    }
}


struct shopItemView : View {
    let category : Filters
    let title : String
    let quantity : Int
    let unit : units
    @Binding var isSelected : Bool
    
    var body: some View {
        VStack(alignment: .leading){
            Text(category.rawValue)
                .foregroundStyle(.blue)
                .bold()
                .font(.system(size: 20))
                .padding(.top)
            RoundedRectangle(cornerRadius: 18)
                .frame(width: .infinity, height: 75)
                .foregroundStyle(.white)
                .overlay {
                    HStack(spacing: 20){
                        if isSelected {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 27, height: 27)
                                .foregroundStyle( isSelected ? Color("primaryColor") : .white )
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                    
                                }
                        }else{
                            
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.pink.opacity(0.6), lineWidth: 2)
                                .frame(width: 28, height: 28)
                            
                        }
                        
                        VStack(alignment: .leading){
                            Text(title)
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                            
                            Text("\(quantity) \(unit)")
                                .foregroundStyle(.gray.opacity(0.5))
                            
                            
                        }
                        Spacer()

                    }.padding(.horizontal)
                    
                    
                }.onTapGesture {
                    withAnimation {
                        isSelected.toggle()

                    }
                    
                }
            

        }.padding(.horizontal)
        
    }
}

struct tabView : View{
    
    let index : Int
    let title : String
    @Binding var selectedTab : Int
    
    var body: some View{
        VStack{
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(selectedTab == index ? Color("primaryColor") : .gray.opacity(0.6))
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 50, height: 3) //check if its the same lenght as the text
                .foregroundStyle(selectedTab == index ? Color("primaryColor") : .blue.opacity(0.05)) //need to check the colot if u chaneg the backgorund

        } //chnage the fromae for the pink to the rounded rectangle
            .onTapGesture {
                withAnimation {
                    selectedTab = index
                }
            }
    }
}


#Preview {
    ShoppingList()
}
