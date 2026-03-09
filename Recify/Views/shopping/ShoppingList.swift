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
    
    // MARK: - Grouping Logic
    //this groups items by their Filters category
    var itemsByType: [Filters: [Ingredients]] {
        Dictionary(grouping: firebaseManager.shoppingItems) { $0.category ?? .other }
    }
    
    //this groups items by the recipe they came from (or "Manually Added" if blank ig)
    var itemsByRecipe: [String: [Ingredients]] {
        Dictionary(grouping: firebaseManager.shoppingItems) { item in
            let name = item.recipeName ?? ""
            return name.isEmpty ? "Manually Added" : name
        }
    }
    
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
                    let itemsToDelete = firebaseManager.shoppingItems.filter { $0.isChecked == true }
                    firebaseManager.clearCompletedShoppingItems(items: itemsToDelete)
                    
                    checkedItems.removeAll()
                }) {
                    Text("Clear Completed")
                        .foregroundStyle(firebaseManager.shoppingItems.filter({ $0.isChecked == true }).isEmpty ? Color.gray : Color("primaryColor"))
                    //.opacity(0.6)
                        .fontWeight(.semibold)
                }
                .disabled(firebaseManager.shoppingItems.filter({ $0.isChecked == true }).isEmpty) //button only works if something is checked
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .overlay(Color.orange.opacity(0.3))
                .padding(.top, 10)
            
            //i dont think we gonna implement this
//            HStack {
//                tabView(index: 0, title: "By Type", selectedTab: $selectedTab)
//                tabView(index: 1, title: "By Recipe", selectedTab: $selectedTab)
//                Spacer()
//            }
//            .padding(.horizontal)
//            .padding(.top)
//            
//            Divider()
//                .overlay(Color.orange.opacity(0.3))
            
            //foreach item the user added to thier shopping list
            ScrollView {
                VStack(spacing: 20) {
                    
                    if selectedTab == 0 {
                        //Show grouped by Type (Category)
                        ForEach(itemsByType.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(category.rawValue)
                                        .foregroundStyle(.blue)
                                        .bold()
                                        .font(.system(size: 20))
                                    
                                    Spacer()
                                    
                                    let checkedInCategory = (itemsByType[category] ?? []).contains(where: { $0.isChecked == true })
                                    
                                    Button(action: {
                                        firebaseManager.moveCategoryItemsToPantry(category: category)
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.seal.fill")
                                            Text("Confirm Type")
                                        }
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(checkedInCategory ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                        .foregroundColor(checkedInCategory ? .blue : .gray)
                                        .cornerRadius(20)
                                    }
                                    .disabled(!checkedInCategory)
                                }
                                .padding(.horizontal)
                                
                                ForEach(itemsByType[category] ?? []) { item in
                                    ShoppingListItemRow(item: item, checkedItems: $checkedItems)
                                }
                            }
                        }
                    } else {
                        //Show grouped by Recipe Name
                        ForEach(itemsByRecipe.keys.sorted(), id: \.self) { recipeName in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(recipeName)
                                        .foregroundStyle(.pink)
                                        .bold()
                                        .font(.system(size: 20))
                                    
                                    Spacer()
                                    
                                    if recipeName != "Manually Added" {
                                        //check if there is at least one checked item in this specific recipe group
                                        let hasCheckedItems = (itemsByRecipe[recipeName] ?? []).contains(where: { $0.isChecked == true })
                                        
                                        Button(action: {
                                            firebaseManager.moveRecipeItemsToPantry(recipeName: recipeName)
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "checkmark.seal.fill")
                                                Text("Confirm Purchase")
                                            }
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(hasCheckedItems ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                                            .foregroundColor(hasCheckedItems ? .green : .gray)
                                            .cornerRadius(20)
                                        }
                                        .disabled(!hasCheckedItems)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ForEach(itemsByRecipe[recipeName] ?? []) { item in
                                    ShoppingListItemRow(item: item, checkedItems: $checkedItems)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .padding(.bottom, 80) // Space for the floating button
            }
            .overlay(
                //the navigation button isnt working any more
                NavigationLink(destination: SearchItemShoppingView()) { //TODO: the button is tin the middle idfk why mb bro
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
                    .padding(),
                alignment: .bottomTrailing
            )
        }
        .background(Color.blue.opacity(0.05))
        .onAppear {
            firebaseManager.fetchShoppingList()
        }
    }
}

// MARK: - Helper Views

struct ShoppingListItemRow: View {
    let item: Ingredients
    @StateObject var firebaseManager = FirebaseViewModel.shared
    @Binding var checkedItems: Set<String>
    
    var body: some View {
        let isSelected = item.isChecked ?? false
        
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
                        Text(item.name)
                            .fontWeight(.semibold)
                            .font(.system(size: 18))
                            .strikethrough(isSelected, color: .gray)
                            .foregroundColor(isSelected ? .gray : .black)
                        
                        Text("\(item.quantity ?? 1) \(item.unit?.rawValue ?? "pcs")")
                            .foregroundStyle(.gray.opacity(0.5))
                            .strikethrough(isSelected, color: .gray.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation {
                    firebaseManager.toggleShoppingItemCheck(item: item)
                    if !isSelected {
                        checkedItems.insert(item.id ?? "")
                    } else {
                        checkedItems.remove(item.id ?? "")
                    }
                }
            }
            .opacity(isSelected ? 0.6 : 1.0)
    }
}


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
                .frame(width: 60, height: 3) //check if its the same lenght as the text
                .foregroundStyle(selectedTab == index ? Color("primaryColor") : Color.blue.opacity(0.05)) //need to check the colot if u chaneg the backgorund
        } //chnage the fromae for the pink to the rounded rectangle
        .onTapGesture {
            withAnimation {
                selectedTab = index
            }
        }
    }
}

struct ShoppingList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShoppingList()
        }
    }
}
          
struct shopItemView: View {
    let title: String
    let quantity: Int
    let unit: units
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading) {

            
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
    }
}
