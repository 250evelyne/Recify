//
//  ShoppingList.swift
//  Recify
//
//  Created by Macbook on 2026-02-21.
//

import SwiftUI

struct ShoppingList: View {
    @State private var selectedTab: Int = 0
    @StateObject var firebaseManager = FirebaseViewModel.shared
    @State private var checkedItems: Set<String> = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "basket.fill")
                    .foregroundStyle(.blue)
                    .font(.title)
                Text("Shopping List")
                    .bold()
                    .font(.system(size: 25))
                
                Spacer()
                
                Button(action: {
                    //this filyer the list for items that are currently checked and delete them
                    let itemsToDelete = firebaseManager.shoppingItems.filter { checkedItems.contains($0.id ?? "") }
                    firebaseManager.clearCompletedShoppingItems(items: itemsToDelete)
                    
                    checkedItems.removeAll()
                }) {
                    Text("Clear Completed")
                        .foregroundStyle(checkedItems.isEmpty ? Color.gray : Color("primaryColor"))
                    //.opacity(0.6)
                        .fontWeight(.semibold)
                }
                .disabled(checkedItems.isEmpty) //button only works if something is checked
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .overlay(Color.orange.opacity(0.3))
                .padding(.top, 10)
            
            HStack {
                tabView(index: 0, title: "By Type", selectedTab: $selectedTab)
                tabView(index: 1, title: "By Recipe", selectedTab: $selectedTab)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .overlay(Color.orange.opacity(0.3))
            
            //foreach item the user added to thier shopping list
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(firebaseManager.shoppingItems) { item in
                        ShoppingListItemRow(item: item, checkedItems: $checkedItems)
                    }
                }
                .padding(.top)
            }
            
            HStack {
                Spacer()
                NavigationLink(destination: SearchItemShoppingView()) { //the navigation button isnt working any more
                    Circle()
                        .shadow(color: .pink.opacity(0.3), radius: 3, y: 2)
                        .foregroundColor(.pink)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .font(.title)
                        }
                }
            }
            .padding()
        }
        .background(Color.blue.opacity(0.05))
        .onAppear {
            firebaseManager.fetchShoppingList()
        }
    }
}

struct ShoppingListItemRow: View {
    let item: Ingredients
    @StateObject var firebaseManager = FirebaseViewModel.shared
    @Binding var checkedItems: Set<String>
    
    var body: some View {
        shopItemView(
            category: item.category ?? .other,
            title: item.name,
            quantity: item.quantity ?? 1,
            unit: item.unit ?? .pcs,
            isSelected: Binding(
                get: { item.isChecked ?? false },
                set: { _ in
                    firebaseManager.toggleShoppingItemCheck(item: item)
                    
                    if !(item.isChecked ?? false) {
                        checkedItems.insert(item.id ?? "")
                    } else {
                        checkedItems.remove(item.id ?? "")
                    }
                }
            )
        )
    }
}

// MARK: - Missing Helper Views

struct tabView: View {
    let index: Int
    let title: String
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(selectedTab == index ? Color("primaryColor") : .gray.opacity(0.6))
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 50, height: 3) //check if its the same lenght as the text
                .foregroundStyle(selectedTab == index ? Color("primaryColor") : Color.blue.opacity(0.05)) //need to check the colot if u chaneg the backgorund
        } //chnage the fromae for the pink to the rounded rectangle
        .onTapGesture {
            withAnimation {
                selectedTab = index
            }
        }
    }
}

struct shopItemView: View {
    let category: Filters
    let title: String
    let quantity: Int
    let unit: units
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category.rawValue)
                .foregroundStyle(.blue)
                .bold()
                .font(.system(size: 20))
                .padding(.top)
                .opacity(isSelected ? 0.5 : 1.0)
            
            RoundedRectangle(cornerRadius: 18)
                .frame(maxWidth: .infinity)
                .frame(height: 75)
                .foregroundStyle(.white)
                .overlay {
                    HStack(spacing: 20) {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 27, height: 27)
                                .foregroundStyle(Color("primaryColor"))
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.pink.opacity(0.6), lineWidth: 2)
                                .frame(width: 28, height: 28)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(title)
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                                .strikethrough(isSelected, color: .gray)
                                .foregroundColor(isSelected ? .gray : .black)
                            
                            Text("\(quantity) \(unit.rawValue)")
                                .foregroundStyle(.gray.opacity(0.5))
                                .strikethrough(isSelected, color: .gray.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .onTapGesture {
                    withAnimation {
                        isSelected.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ShoppingList()
}
