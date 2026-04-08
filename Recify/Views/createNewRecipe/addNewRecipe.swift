//
//  addNewRecipe.swift
//  Recify
//
//  Created by Macbook on 2026-03-26.
//

import SwiftUI
import Photos

struct addNewRecipe: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var firebaseVM = FirebaseViewModel.shared
    
    // Image Picker States
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var showPermissionDeniedAlert = false
    @State private var isUploading = false
    
    // Recipe Data States
    @State private var recipeTitle: String = ""
    @State private var calories: String = ""
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var prepTime: Int = 0
    @State private var instructions: [String] = []
    @State private var ingredients: [Ingredients] = []
    @State private var ingredientStrings: [String] = []
    
    @State private var recipeIngredients: [Ingredients] = []
    
    // Sheet States
    @State private var showAddIngredient = false
    @State private var showAddStep = false
    
    @State private var showSuccessAlert = false
    
    @State private var isNameTaken = false
    @State private var showingDuplicateAlert = false
    
    @State private var showClearConfirmation = false
    
    // MARK: - Validation Logic
    private var isFormValid: Bool {
        let hasTitle = !recipeTitle.trimmingCharacters(in: .whitespaces).isEmpty
        let hasIngredients = !ingredients.isEmpty
        let hasInstructions = !instructions.isEmpty
        let hasDifficulty = selectedDifficulty != nil
        let hasPrepTime = prepTime > 0
        let hasCalories = !calories.isEmpty
        let hasImage = selectedImage != nil
        
        return hasTitle && hasIngredients && hasInstructions && hasDifficulty && hasPrepTime && hasCalories && hasImage
    }
    
    private func resetForm() {
        recipeTitle = ""
        calories = ""
        selectedDifficulty = nil
        prepTime = 0
        instructions = []
        ingredients = []
        ingredientStrings = []
        selectedImage = nil
    }
    
    private func syncIngredientStrings() {
        ingredientStrings = ingredients.map { $0.displayText }
    } //for the listview
    
    // Helper to ask for photo library permission
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showImagePicker = true
                    } else {
                        showPermissionDeniedAlert = true
                    }
                }
            }
        case .authorized, .limited:
            showImagePicker = true
        default:
            showPermissionDeniedAlert = true
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20){
                
                // MARK: - Photo Upload Section
                Button(action: {
                    checkPhotoLibraryPermission()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(Color.pink.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                            .foregroundStyle(.pink.opacity(0.1))
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
                        } else {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.pink)
                                    .padding(15)
                                    .background(Circle().fill(Color.white))
                                
                                Text("Upload a Cover photo")
                                    .foregroundStyle(.pink)
                                    .bold()
                                    .font(.title3)
                                
                                Text("Add a beautiful image of your finished dish")
                                    .foregroundStyle(.pink.opacity(0.3))
                                    .bold()
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Group {
                    // MARK: - General Info Header with Clear All
                    HStack {
                        Text("General Information")
                            .fontWeight(.semibold)
                            .font(.title3)
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Text("Clear All")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle((recipeTitle.isEmpty && ingredients.isEmpty && instructions.isEmpty && selectedImage == nil) ? .gray : .pink)
                        }
                        .disabled(recipeTitle.isEmpty && ingredients.isEmpty && instructions.isEmpty && selectedImage == nil)
                    }
                    .padding(.top)
                    
                    Text("Recipe Title")
                        .foregroundStyle(recipeTitle.isEmpty ? .pink : .gray)
                    GroupBox {
                        Section {
                            TextField("e.g. Grandma's Apple Pie", text: $recipeTitle)
                        }
                    }
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Difficulty")
                                .foregroundStyle(selectedDifficulty == nil ? .pink : .gray)
                            GroupBox{
                                Menu {
                                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                                        Button(difficulty.rawValue.capitalized) {
                                            selectedDifficulty = difficulty
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedDifficulty?.rawValue.capitalized ?? "Select Difficulty")
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(.pink)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading){
                            Text("Calories")
                                .foregroundStyle(calories.isEmpty ? .pink : .gray)
                            GroupBox{
                                Section {
                                    TextField("e.g. 450 kcals", text: $calories)
                                        .keyboardType(.numberPad)
                                }
                            }
                        }
                    }
                    
                    Text("Prep Time")
                        .foregroundStyle(prepTime == 0 ? .pink : .gray)
                    HStack(spacing: 20){
                        btnView(time: $prepTime, btnTime: 15)
                        btnView(time: $prepTime, btnTime: 30)
                        btnView(time: $prepTime, btnTime: 45)
                        
                        Button {
                            prepTime = (prepTime == 60 ? 0 : 60)
                        } label: {
                            Text("1h+")
                        }
                        .buttonStyle(.bordered)
                        .tint(prepTime == 60 ? .pink : .gray)
                        .font(.system(size: 20))
                    }
                }
                
                Group {
                    ListView(
                        title: "Ingredients",
                        destination: "addNewIngredient",
                        items: $ingredientStrings,
                        ingredients: $ingredients,
                        emptyMessage: "No ingredients added yet",
                        buttonText: "ADD ITEM",
                        systemImage: "fork.knife"){
                            showAddIngredient = true
                        }
                    
                    if instructions.isEmpty {
                        ListView(
                            title:"Instructions",
                            destination: "AddStep",
                            items: $instructions,
                            ingredients: $ingredients,
                            emptyMessage: "Start adding your cooking steps",
                            buttonText: "ADD STEP",
                            systemImage: "list.bullet"
                        ){
                            showAddStep = true
                        }
                    } else {
                        HStack(alignment: .bottom){
                            Text("Instructions")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .padding(.top)
                            
                            Spacer()
                            
                            Button{
                                showAddStep = true
                            } label: {
                                Label("ADD STEP", systemImage: "plus.circle.fill")
                                    .foregroundStyle(.pink)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        ForEach(Array(instructions.indices), id: \.self) { index in
                            StepRow(step: instructions[index], index: index){
                                instructions.remove(at: index)
                            }
                        }
                    }
                }
                
                // MARK: - Post Recipe Button
                HStack{
                    Spacer()
                    
                    Button {
                        isUploading = true
                        
                        Task {
                            let exists = await firebaseVM.recipeExists(title: recipeTitle.trimmingCharacters(in: .whitespaces))
                            
                            if exists {
                                isUploading = false
                                showingDuplicateAlert = true
                            } else {
                                firebaseVM.saveNewRecipe(
                                    title: recipeTitle,
                                    caloriesString: calories,
                                    prepTime: prepTime,
                                    difficulty: selectedDifficulty?.rawValue ?? "Easy",
                                    ingredients: ingredients,
                                    instructionsArray: instructions,
                                    coverImage: selectedImage
                                ) { success in
                                    isUploading = false
                                    if success {
                                        showSuccessAlert = true
                                    }
                                }
                            }
                        }
                    } label: {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                                .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                        } else {
                            Label("Post recipe", systemImage: "plus.circle.fill")
                                .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                        }
                    }
                    .font(.title2)
                    .buttonStyle(.bordered)
                    .tint(.pink)
                    .disabled(!isFormValid || isUploading)
                    
                    Spacer()
                }
                
            }//end of vstack
            .padding()
            // MARK: - Alerts
            .alert("Name Already Taken", isPresented: $showingDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("A recipe with the name '\(recipeTitle)' already exists. Please choose a different name.")
            }
        }
        .navigationTitle("Add New Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
        // MARK: - Modifiers
        .sheet(isPresented: $showAddIngredient) {
            AddIngredient { selected in
                ingredients.append(contentsOf: selected)
                syncIngredientStrings()
            }
            .presentationDetents([.fraction(0.80), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddStep) {
            AddStep(onAdd: { step in
                instructions.append(step)
            }, stepCount: instructions.count + 1)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert("Recipe Saved!", isPresented: $showSuccessAlert) {
            Button("OK") {
                resetForm()
                dismiss()
            }
        } message: {
            Text("Your recipe has been successfully posted to your collection.")
        }
        .confirmationDialog("Clear everything?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                resetForm()
            }
            Button("Keep Editing", role: .cancel) { }
        } message: {
            Text("This will delete all progress on this recipe.")
        }
    }
}

// MARK: - Subviews
struct btnView: View {
    @Binding var time: Int
    let btnTime: Int
    
    var body: some View {
        Button {
            time = (time == btnTime ? 0 : btnTime)
        } label: {
            Text("\(btnTime)m")
        }
        .buttonStyle(.bordered)
        .tint(time == btnTime ? .pink : .gray)
    }
}

struct StepRow: View {
    var step: String
    var index: Int
    var onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("STEP \(index + 1)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.pink)
            
            HStack{
                Text(step)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineSpacing(4)
                Spacer()
                
                Button {
                    onDelete?()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ListView: View {
    var title: String
    var destination : String
    @Binding var items: [String]
    @Binding var ingredients: [Ingredients]
    var emptyMessage: String
    var buttonText: String
    var systemImage: String
    var onAdd: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom){
                Text(title)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .foregroundStyle(items.isEmpty ? .pink : .primary)
                    .padding(.top)
                
                Spacer()
                
                Button {
                    onAdd()
                } label: {
                    Label(buttonText, systemImage: "plus.circle.fill")
                        .foregroundStyle(.pink)
                        .fontWeight(.semibold)
                }
            }
            
            if !items.isEmpty {
                ForEach(Array(items.indices), id: \.self) { index in
                    HStack {
                        Text(items[index])
                            .font(.body)
                        
                        Spacer()
                        
                        Button {
                            let removed = items.remove(at: index)
                            ingredients.removeAll { $0.displayText == removed }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.gray)
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.gray.opacity(0.5),
                                  style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                    .frame(height: 150)
                    .overlay {
                        VStack {
                            Image(systemName: systemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.gray.opacity(0.4))
                            
                            Text(emptyMessage)
                                .foregroundStyle(.gray.opacity(0.5))
                                .bold()
                                .font(.subheadline)
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}

#Preview {
    addNewRecipe()
}
