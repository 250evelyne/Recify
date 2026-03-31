//
//  addNewRecipe.swift
//  Recify
//
//  Created by Macbook on 2026-03-26.
//

import SwiftUI

struct addNewRecipe: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipeTitle: String = ""
    @State private var calories: String = ""
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var prepTime: Int = 0
    @State private var instructions: [String] = []
    @State private var ingredients: [Ingredients] = []
  @State private var ingredientStrings: [String] = []
    
    private func syncIngredientStrings() {
        ingredientStrings = ingredients.map { $0.displayText }
    } //for the listview
    
    
    @State private var recipeIngredients: [Ingredients] = []
    
    @State private var showAddIngredient = false
    @State private var showAddStep = false

//    let mockIngredients: [Ingredients] = [
//        Ingredients(
//            id: "1",
//            apiId: nil,
//            name: "Eggs",
//            quantity: 2,
//            unit: .pcs,
//            imageUrl: "",
//            category: nil,
//            isChecked: false,
//            timestamp: Date(),
//            recipeName: "Omelette",
//            inPantry: true
//        ),
//        Ingredients(
//            id: "2",
//            apiId: nil,
//            name: "Flour",
//            quantity: 200,
//            unit: .grams,
//            imageUrl: "",
//            category: nil,
//            isChecked: false,
//            timestamp: Date(),
//            recipeName: "Pancakes",
//            inPantry: false
//        ),
//        Ingredients(
//            id: "3",
//            apiId: nil,
//            name: "Milk",
//            quantity: 250,
//            unit: .ml,
//            imageUrl: "",
//            category: nil,
//            isChecked: false,
//            timestamp: Date(),
//            recipeName: "Pancakes",
//            inPantry: true
//        ),
//        Ingredients(
//            id: "4",
//            apiId: nil,
//            name: "Butter",
//            quantity: 50,
//            unit: .grams,
//            imageUrl: "",
//            category: nil,
//            isChecked: false,
//            timestamp: Date(),
//            recipeName: "Toast",
//            inPantry: true
//        )
//    ]
    
//    let mockSteps: [String] = [
//        "Crack the eggs into a bowl",
//        "Whisk the eggs until smooth",
//        "Heat a pan over medium heat",
//        "Pour the mixture into the pan",
//        "Cook for 3-5 minutes until set",
//        "Serve while hot"
//    ]
    
    var body: some View {
//        NavigationStack{ //TODO: ima take this off becuase the idmiss dosnt work any way on the tab view cuase there nothing to dismiss and i hope that the tolbar will pop up when they nagivate to this page from the profile
            ScrollView {
                VStack(alignment: .leading, spacing: 20){
                    
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.pink.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                        .foregroundStyle(.pink.opacity(0.1))
                        .frame(height: 300)
                    
                        .overlay {
                            VStack {
                                Image(systemName: "camera.fill") //TODO: ask for permission like the locaiton permission, then we get the path where the image is stored and then u store it in the firebase
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.pink)
                                    .padding(15)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                    )
                                
                                Text("Upload a Cover photo")
                                    .foregroundStyle(.pink)
                                    .bold()
                                    .font(.title3)
                                
                                Text("Add a beautiful image of your finished dish")
                                    .foregroundStyle(.pink.opacity(0.3))
                                    .bold()
                                    .font(.subheadline)
                            }
                        }
                        .background(Color.pink.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
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
                    
                    //TODO: add destination to sheet to add iten or step
                    ListView(
                        title: "Ingredients",
                        destination: "addNewIngredient",
//                        items: $ingredients.map { $0.displayText},
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
                            ingredients: $ingredients, //just ignore this line its only for the ingredients ill check if it fucks with anything
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
//                                AddStep(stepCount: instructions.count + 1)
                            } label: {
                                Label("ADD STEP", systemImage: "plus.circle.fill")
                                    .foregroundStyle(.pink)
                                    .fontWeight(.semibold)
                            }
                        }
                        ForEach(instructions.indices, id: \.self) { index in
                            StepRow(step: instructions[index], index: index){
                                instructions.remove(at: index)
                            }
                        }
                    }
                    
                    HStack{
                        Spacer()
                        
                        Button {
                            //TODO: add save a recoipe funciton perhaps anabella
                        } label: {
                            Label("Post recipe", systemImage: "plus.circle.fill")
                                .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                            
                        }.font(.title2)
                            .buttonStyle(.bordered)
                            .tint(.pink)
                        
                        Spacer()
                    }
                    
                    
                    
                }//end of vstack
                .padding()
            }//end of scroll view
            .sheet(isPresented: $showAddIngredient) {
                AddIngredient { selected in
                    ingredients.append(contentsOf: selected)//we can add multiple ingredients at once
                    syncIngredientStrings()
                }
                .presentationDetents([
                    .fraction(0.80), //LIKE 2/3rd I wanted the users to be able to see ingredients properly
                    .large
                ])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddStep) {
                AddStep(onAdd: { step in
                    instructions.append(step)
                }, stepCount: instructions.count + 1)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .navigationTitle("Add New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    
                }
            }//end of tool var
//        }//end of navigation
    }
}

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
                //TODO: add alter to delete item and func to actually delete it
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
    @Binding var items: [String]/*?*/
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

            if /*var items = items ,*/ !items.isEmpty {
                ForEach(items.indices, id: \.self) { index in
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
