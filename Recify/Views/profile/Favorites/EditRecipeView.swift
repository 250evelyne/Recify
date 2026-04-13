//
//  EditRecipeView.swift
//  Recify
//
//  Created by netblen on 13-04-2026.
//

import SwiftUI
import Photos

struct EditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var firebaseVM = FirebaseViewModel.shared 
    
    let recipe: Recipe
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var showPermissionDeniedAlert = false
    @State private var isUploading = false
    
    @State private var recipeTitle: String
    @State private var calories: String
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var prepTime: Int
    @State private var instructions: [String]
    @State private var ingredients: [Ingredients] = []
    @State private var ingredientStrings: [String]
    
    @State private var showAddIngredient = false
    @State private var showAddStep = false
    @State private var showSuccessAlert = false
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        _recipeTitle = State(initialValue: recipe.title)
        _calories = State(initialValue: String(recipe.calories ?? 0))
        
        let levelMatch = DifficultyLevel.allCases.first(where: { $0.rawValue.lowercased() == recipe.level.lowercased() })
        _selectedDifficulty = State(initialValue: levelMatch)
        
        _prepTime = State(initialValue: recipe.prepTime)
        _instructions = State(initialValue: recipe.instructions.components(separatedBy: "\n").filter { !$0.isEmpty })
        _ingredientStrings = State(initialValue: recipe.ingredients)
    }
    
    private var isFormValid: Bool {
        let hasTitle = !recipeTitle.trimmingCharacters(in: .whitespaces).isEmpty
        let hasInstructions = !instructions.isEmpty
        let hasDifficulty = selectedDifficulty != nil
        let hasPrepTime = prepTime > 0
        let hasCalories = !calories.isEmpty
        return hasTitle && hasInstructions && hasDifficulty && hasPrepTime && hasCalories
    }
    
    private func syncIngredientStrings() {
        ingredientStrings = ingredients.map { $0.displayText }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Photo Upload Section
                    Button(action: { showImagePicker = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color.pink.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                                .frame(maxWidth: 360, minHeight: 300, maxHeight: 300)
                                .background(Color.pink.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 360, maxHeight: 300)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else if let existingBase64 = recipe.imageURL, let data = Data(base64Encoded: existingBase64), let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 360, maxHeight: 300)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundStyle(.pink)
                                        .padding(15)
                                        .background(Circle().fill(Color.white))
                                    Text("Change Cover photo").foregroundStyle(.pink).bold().font(.title3)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Group {
                        Text("General Information").fontWeight(.semibold).font(.title3)
                        
                        Text("Recipe Title").foregroundStyle(recipeTitle.isEmpty ? .pink : .gray)
                        GroupBox { TextField("e.g. Grandma's Apple Pie", text: $recipeTitle) }
                        
                        HStack {
                            VStack(alignment: .leading){
                                Text("Difficulty").foregroundStyle(selectedDifficulty == nil ? .pink : .gray)
                                GroupBox {
                                    Menu {
                                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                                            Button(difficulty.rawValue.capitalized) { selectedDifficulty = difficulty }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedDifficulty?.rawValue.capitalized ?? "Select Difficulty")
                                            Image(systemName: "chevron.down")
                                        }.foregroundColor(.pink)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Calories").foregroundStyle(calories.isEmpty ? .pink : .gray)
                                GroupBox {
                                    TextField("e.g. 450", text: $calories).keyboardType(.numberPad)
                                }
                            }
                        }
                        
                        Text("Prep Time").foregroundStyle(prepTime == 0 ? .pink : .gray)
                        HStack(spacing: 20){
                            btnView(time: $prepTime, btnTime: 15)
                            btnView(time: $prepTime, btnTime: 30)
                            btnView(time: $prepTime, btnTime: 45)
                            Button { prepTime = (prepTime == 60 ? 0 : 60) } label: { Text("1h+") }
                                .buttonStyle(.bordered)
                                .tint(prepTime == 60 ? .pink : .gray)
                        }
                    }
                    
                    Group {
                        ListView(
                            title: "Ingredients", destination: "addNewIngredient",
                            items: $ingredientStrings, ingredients: $ingredients,
                            emptyMessage: "No ingredients added yet", buttonText: "ADD ITEM",
                            systemImage: "fork.knife") { showAddIngredient = true }
                        
                        HStack(alignment: .bottom){
                            Text("Instructions").fontWeight(.semibold).font(.title3).padding(.top)
                            Spacer()
                            Button{ showAddStep = true } label: {
                                Label("ADD STEP", systemImage: "plus.circle.fill").foregroundStyle(.pink).fontWeight(.semibold)
                            }
                        }
                        
                        ForEach(Array(instructions.indices), id: \.self) { index in
                            StepRow(step: instructions[index], index: index) { instructions.remove(at: index) }
                        }
                    }
                    
                    // MARK: - Update Button
                    HStack {
                        Spacer()
                        Button {
                            isUploading = true
                            guard let id = recipe.id else { return }
                            
                            firebaseVM.updateRecipe(
                                recipeId: id,
                                title: recipeTitle,
                                caloriesString: calories,
                                prepTime: prepTime,
                                difficulty: selectedDifficulty?.rawValue ?? "Easy",
                                ingredientStrings: ingredientStrings,
                                instructionsArray: instructions,
                                newCoverImage: selectedImage,
                                existingImageURL: recipe.imageURL
                            ) { success in
                                isUploading = false
                                if success { showSuccessAlert = true }
                            }
                        } label: {
                            if isUploading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .pink))
                                    .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                            } else {
                                Label("Save Changes", systemImage: "checkmark.circle.fill")
                                    .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                            }
                        }
                        .font(.title2).buttonStyle(.bordered).tint(.pink).disabled(!isFormValid || isUploading)
                        Spacer()
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredient { selected in
                    ingredients.append(contentsOf: selected)
                    syncIngredientStrings()
                }.presentationDetents([.fraction(0.80), .large])
            }
            .sheet(isPresented: $showAddStep) {
                AddStep(onAdd: { step in instructions.append(step) }, stepCount: instructions.count + 1)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showImagePicker) { ImagePicker(selectedImage: $selectedImage) }
            .alert("Recipe Updated!", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            }
        }
    }
}
