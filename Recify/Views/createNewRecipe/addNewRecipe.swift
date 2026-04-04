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
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            .background(Color.pink.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 300)
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
                    Text("General Information")
                        .fontWeight(.semibold)
                        .font(.title3)
                    
                    Text("Recipe Title")
                        .foregroundStyle(.gray)
                    GroupBox{
                        Section {
                            TextField("e.g. Grandma's Apple Pie", text: $recipeTitle)
                        }
                    }
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Difficulty")
                                .foregroundStyle(.gray)
                            GroupBox{
                                Menu {
                                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                                        Button(difficulty.rawValue.capitalized) {
                                            selectedDifficulty = difficulty
                                        }
                                    }
                                } label: {
                                    Text(selectedDifficulty?.rawValue.capitalized ?? "Select Difficulty")
                                        .foregroundColor(.pink)
                                    Image(systemName: "chevron.down")                        .foregroundColor(.gray)
                                    
                                }
                            }
                        }
                        
                        VStack(alignment: .leading){
                            Text("Calories")
                                .foregroundStyle(.gray)
                            GroupBox{
                                Section {
                                    TextField("e.g. 450 kcals", text: $calories)
                                }
                            }
                        }
                    }
                    
                    Text("Prep Time")
                        .foregroundStyle(.gray)
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
                            ingredients: $ingredients, //just ignore this line its only for the ingredients
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
                                dismiss()
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
                    .disabled(recipeTitle.isEmpty || isUploading)
                    
                    Spacer()
                }
                
            }//end of vstack
            .padding()
        }//end of scroll view
        
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
        .alert("Permission Denied", isPresented: $showPermissionDeniedAlert) {
            Button("OK", role: .cancel) { }
            Button("Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        } message: {
            Text("Please allow access to your photos in Settings to upload a cover image.")
        }
        .navigationTitle("Add New Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
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
