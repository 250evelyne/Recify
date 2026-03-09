//
//  CalendarView.swift
//
//
//  Created by mac on 2026-03-07.
//


import SwiftUI

struct RecipeInstructionsView: View {
    
    let recipeTitle: String
    let recipeImage: String
    let rating: Double
    let reviewCount: String
    let prepTime: String
    let calories: String
    let difficulty: String
    let ingredients: [RecipeIngredient]
    let instructions: [String]
    let isEditorChoice: Bool
    
    @Environment(\.dismiss) var dismiss
    @State private var isFavorite = false
    @State private var showCalendar = false
    
    var pantryCount: Int {
        ingredients.filter { $0.inPantry }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Recipe Img
                    ZStack(alignment: .bottomLeading) {
                        
                        Image(recipeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .clipped()
                        
                        
                        if isEditorChoice {
                            Text("EDITOR'S CHOICE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(20)
                                .padding()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Recipe Title
                        Text(recipeTitle)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Rating
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(rating) ? "star.fill" : (index == Int(rating) && rating.truncatingRemainder(dividingBy: 1) >= 0.5 ? "star.leadinghalf.filled" : "star"))
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                            Text("\(String(format: "%.1f", rating)) (\(reviewCount) reviews)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        
                        HStack(spacing: 12) {
                            InfoCard(title: "PREP TIME", value: prepTime, color: Color(red: 0.68, green: 0.85, blue: 0.90))
                            InfoCard(title: "CALORIES", value: calories, color: Color(red: 1.0, green: 0.95, blue: 0.95))
                            InfoCard(title: "LEVEL", value: difficulty, color: Color(red: 0.88, green: 0.98, blue: 0.88))
                        }
                        
                        // Ingredients Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Ingredients")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(pantryCount)/\(ingredients.count) in pantry")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }
                            
                            
                            ForEach(ingredients) { ingredient in
                                IngredientRow(name: ingredient.name, inPantry: ingredient.inPantry)
                            }
                        }
                        .padding(.top, 10)
                        
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                                InstructionStep(
                                    number: index + 1,
                                    text: instruction,
                                    color: index % 2 == 0 ? Color(red: 0.68, green: 0.85, blue: 0.90) : Color(red: 1.0, green: 0.95, blue: 0.95)
                                )
                            }
                        }
                        .padding(.top, 10)
                        
                        // Start cooking btn
                        NavigationLink(destination: CookingModeTabView(
                            recipeTitle: recipeTitle,
                            steps: instructions
                        )) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Start Cooking")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(12)
                        }
                        
                        // Add to Calendar Button
                        Button(action: {
                            showCalendar = true
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Add to Planner")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Recipe Details")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isFavorite.toggle() }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .pink : .pink)
                            .padding(8)
                            .background(Color.pink.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showCalendar) {
                CalendarView()
            }
        }
    }
}



struct RecipeIngredient: Identifiable {
    let id = UUID()
    let name: String
    let inPantry: Bool
}

//supporting views


struct InfoCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(12)
    }
}

struct IngredientRow: View {
    let name: String
    let inPantry: Bool
    
    var body: some View {
        HStack {
            Image(systemName: inPantry ? "checkmark.circle.fill" : "plus.circle.fill")
                .foregroundColor(inPantry ? .green : .pink)
                .font(.title3)
            
            Text(name)
                .font(.body)
            
            Spacer()
            
            Text(inPantry ? "IN PANTRY" : "TO BUY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(inPantry ? .green : .pink)
        }
        .padding()
        .background(inPantry ? Color.green.opacity(0.1) : Color.pink.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

///sample data

struct RecipeInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeInstructionsView(
            recipeTitle: "Creamy Avocado Pasta",
            recipeImage: "pasta-sample",
            rating: 4.8,
            reviewCount: "1.2k",
            prepTime: "15 min",
            calories: "450 kcal",
            difficulty: "Easy",
            ingredients: [
                RecipeIngredient(name: "Ripe Avocados (2)", inPantry: true),
                RecipeIngredient(name: "Garlic (3 cloves)", inPantry: true),
                RecipeIngredient(name: "Whole Grain Pasta (500g)", inPantry: false),
                RecipeIngredient(name: "Olive Oil (2 tbsp)", inPantry: true),
                RecipeIngredient(name: "Salt (1 tsp)", inPantry: true),
                RecipeIngredient(name: "Black Pepper (1/2 tsp)", inPantry: true),
                RecipeIngredient(name: "Lemon Juice (1 tbsp)", inPantry: false),
                RecipeIngredient(name: "Fresh Basil (optional)", inPantry: false),
                RecipeIngredient(name: "Parmesan Cheese (50g)", inPantry: false)
            ],
            instructions: [
                "Bring a large pot of salted water to a boil. Cook the pasta according to package instructions until al dente.",
                "While pasta cooks, blend the avocados, garlic, and olive oil in a food processor until smooth and creamy.",
                "Drain pasta and toss with avocado sauce. Season with salt and pepper to taste. Serve immediately."
            ],
            isEditorChoice: true
        )
    }
}
