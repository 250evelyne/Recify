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
    
    //fyi for later he @state maeks it mutable thats why our toggle wasnt working
    @State private var ingredientSelected : Bool = false
    //the  list of ingredients the users wants to add?? not sure how ima do that, or like for now ima just keep track of the check box
    @State private var quantity : Int = 1
    @State private var selectedUnits: units = units.pcs
    
    //manual initializer to handle both the simple call and the trailing closure call
    init(ingredient: Ingredients, onSelect: ((Ingredients) -> Void)? = nil) {
        self.ingredient = ingredient
        self.onSelect = onSelect
    }
    
    var body: some View {
        ZStack {
            // Background Card
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5)
            
            // Border
            RoundedRectangle(cornerRadius: 20)
                .stroke(ingredientSelected ? Color.pink : Color.gray.opacity(0.1),
                        lineWidth: ingredientSelected ? 3 : 1)
            
            VStack(spacing: 0) {
                mainRow
                
                if ingredientSelected {
                    Divider().padding(.vertical, 8)
                    quantityAndUnitSelectors
                }
            }
            .padding()
        }
        .frame(width: 360)
        .frame(height: ingredientSelected ? 200 : 100)
        .animation(.easeInOut(duration: 0.4), value: ingredientSelected)///anaimation kinda ugly might change it later
        .padding(5)
        .onChange(of: quantity) { _ in sendUpdate() }
        .onChange(of: selectedUnits) { _ in sendUpdate() }
    }
    
    // MARK: - Subviews
    
    private var mainRow: some View {
        HStack {
            imageSection
            
            VStack(alignment: .leading) {
                Text(ingredient.name)
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                Text(ingredient.category?.rawValue ?? "N/A")
                    .foregroundStyle(.gray)
                    .font(.system(size: 13))
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button {
                ingredientSelected.toggle()
                if ingredientSelected { sendUpdate() }
                
                //add the actions for the pink check twhen its clicked
                
                //if they unselect it, we should probably remove it from the parent list
                // but for now, we trigger onSelect when they actually click the "Add" button below
                
            } label: {
                Image(systemName: ingredientSelected ? "checkmark.circle.fill" : "plus")
                    .foregroundStyle(ingredientSelected ? .pink : .gray)
                    .font(.title)
            }
        }
    }
    
    private var imageSection: some View {
        AsyncImage(url: URL(string: ingredient.imageUrl)) { phase in
            if let image = phase.image {
                image.resizable()
                    .frame(width: 65, height: 65)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
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
    }
    
    private var quantityAndUnitSelectors: some View {
        VStack {
            HStack {
                Text("QUANTITY").font(.system(size: 11)).bold().foregroundColor(.gray)
                Spacer()
                Text("UNIT").font(.system(size: 11)).bold().foregroundColor(.gray)
            }
            
            HStack {
                HStack(spacing: 15) {
                    Button(action: { if quantity > 0 { quantity -= 1 } }) {
                        controlCircle(systemName: "minus", isHighlighted: false)
                    }
                    
                    Text("\(quantity)")
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                    
                    Button(action: { quantity += 1 }) {
                        controlCircle(systemName: "plus", isHighlighted: true)
                    }
                }
                
                Spacer()
                
                // Unit Picker
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray.opacity(0.1))
                    .frame(width: 100, height: 45)
                    .overlay {
                        Picker("", selection: $selectedUnits) {
                            //loki really wide and i dont like the look but wtv
                            ForEach(units.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.black)
                    }
            }
        }
    }
    
    private func controlCircle(systemName: String, isHighlighted: Bool) -> some View {
        Circle()
            .fill(isHighlighted ? Color.pink.opacity(0.2) : Color.white)
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .frame(width: 35, height: 35)
            .overlay {
                Image(systemName: systemName)
                    .foregroundColor(isHighlighted ? .pink : .black)
                    .font(.footnote.bold())
            }
    }
    
    private func sendUpdate() {
        let updatedIngredient = Ingredients(
            id: ingredient.id,
            name: ingredient.name,
            quantity: quantity,
            unit: selectedUnits,
            imageUrl: ingredient.imageUrl,
            category: ingredient.category
        )
        onSelect?(updatedIngredient)
    }
}


#Preview {
    IngredientsView(ingredient: Ingredients(id: "1", name: "Carrot", quantity: 5, unit: .cups, imageUrl: "https://spoonacular.com/cdn/ingredients_100x100/carrot.png", category: .vegetables))
}
