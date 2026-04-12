//
//  CalendarView.swift
//  Recify
//
//  Created by mac on 2026-03-07.
//


import SwiftUI


struct CalendarView: View {
    let recipeId: String?
    let recipeName: String?
    let recipeImage: String?
    let prepTime: Int?
    let difficulty: String?
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedMeal: String = "Lunch"
    @State private var showConfirmation = false
    @State private var showDuplicateAlert = false
    @State private var savedMeals: [SavedMeal] = []
    @State private var selectedRecipe: SavedMeal? = nil
    @State private var showRecipeSheet = false
    
    let meals = ["Breakfast", "Lunch", "Dinner"]
    
    init(recipeId: String? = nil,
         recipeName: String? = nil,
         recipeImage: String? = nil,
         prepTime: Int? = nil,
         difficulty: String? = nil) {
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.recipeImage = recipeImage
        self.prepTime = prepTime
        self.difficulty = difficulty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.3),
                        Color.pink.opacity(0.1),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 0) {
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                        
                        mealsSection
                        
                        if recipeId != nil {
                            addRecipeSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Meal Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(recipeId != nil ? "Cancel" : "Done") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                    .fontWeight(.semibold)
                }
            }
            .alert("Added!", isPresented: $showConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("\(recipeName ?? "Recipe") added to \(selectedMeal)")
            }
            .alert("Already Planned", isPresented: $showDuplicateAlert) {
                Button("Replace", role: .destructive) {
                    replaceMeal()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You already have a \(selectedMeal) planned for this day. Do you want to replace it?")
            }
            .onAppear {
                loadMeals()
            }
        }
    }
    
    private var mealsSection: some View {
        let mealsForDate = savedMeals.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isToday ? "Today's Meals" : formattedDate)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !mealsForDate.isEmpty {
                        Text("\(mealsForDate.count) meal\(mealsForDate.count == 1 ? "" : "s") planned")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isToday {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.4),
                        Color.pink.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            
            if mealsForDate.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(mealsForDate) { meal in
                        Button(action: {
                            selectedRecipe = meal
                            showRecipeSheet = true
                        }) {
                            MealRow(meal: meal, onDelete: {
                                deleteMealImmediately(meal)
                            })
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .sheet(item: $selectedRecipe) { meal in
            RecipeInstructionsView(
                mealId: meal.recipeId,
                recipeTitle: meal.recipeName,
                recipeImage: meal.recipeImage ?? "",
                prepTime: meal.prepTime,
                difficulty: meal.difficulty
            )
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.3),
                                Color.pink.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 35))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            Text("No meals planned")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add a recipe to start planning")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white.opacity(0.7))
        .cornerRadius(16)
    }
    
    private var addRecipeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add to This Day")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach(meals, id: \.self) { meal in
                    Button(meal) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMeal = meal
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedMeal == meal ? .white : .primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if selectedMeal == meal {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pink, Color.pink.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.white]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                    )
                    .cornerRadius(25)
                    .shadow(color: selectedMeal == meal ? Color.pink.opacity(0.3) : Color.black.opacity(0.05), radius: 8, y: 4)
                }
            }
            
            if let name = recipeName {
                HStack(spacing: 14) {
                    if let image = recipeImage {
                        AsyncImage(url: URL(string: image)) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            default:
                                placeholderImage
                            }
                        }
                    } else {
                        placeholderImage
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Adding:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(name)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        HStack(spacing: 8) {
                            if let prep = prepTime {
                                Label("\(prep)m", systemImage: "clock")
                                    .font(.caption2)
                            }
                            if let diff = difficulty {
                                Label(diff, systemImage: "chart.bar")
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.2),
                            Color.pink.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
            }
            
            Button(action: saveMeal) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.headline)
                    Text("Add to Planner")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.pink, Color.pink.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.pink.opacity(0.4), radius: 10, y: 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.3),
                        Color.pink.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 70, height: 70)
            .overlay(
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundColor(.gray.opacity(0.5))
            )
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }
    
    private func loadMeals() {
        savedMeals = MealPlannerManager.shared.getAllMeals()
    }
    
    private func saveMeal() {
        guard let recipeId = recipeId, let recipeName = recipeName else { return }
        
        let existingMeal = savedMeals.first { meal in
            Calendar.current.isDate(meal.date, inSameDayAs: selectedDate) &&
            meal.mealType == selectedMeal
        }
        
        if existingMeal != nil {
            showDuplicateAlert = true
            return
        }
        
        let newMeal = SavedMeal(
            recipeId: recipeId,
            recipeName: recipeName,
            recipeImage: recipeImage,
            date: selectedDate,
            mealType: selectedMeal,
            prepTime: prepTime ?? 30,
            difficulty: difficulty ?? "Medium"
        )
        
        MealPlannerManager.shared.saveMeal(newMeal)
        loadMeals()
        showConfirmation = true
       
    }
    
    private func replaceMeal() {
        guard let recipeId = recipeId, let recipeName = recipeName else { return }
        
        if let existingMeal = savedMeals.first(where: { meal in
            Calendar.current.isDate(meal.date, inSameDayAs: selectedDate) &&
            meal.mealType == selectedMeal
        }) {
            MealPlannerManager.shared.deleteMeal(id: existingMeal.id)
        }
        
        let newMeal = SavedMeal(
            recipeId: recipeId,
            recipeName: recipeName,
            recipeImage: recipeImage,
            date: selectedDate,
            mealType: selectedMeal,
            prepTime: prepTime ?? 30,
            difficulty: difficulty ?? "Medium"
        )
        
        MealPlannerManager.shared.saveMeal(newMeal)
        loadMeals()
        showConfirmation = true
       
    }
    
    private func deleteMealImmediately(_ meal: SavedMeal) {
        MealPlannerManager.shared.deleteMeal(id: meal.id)
        withAnimation {
            savedMeals.removeAll { $0.id == meal.id }
        }
       
    }
}

struct MealRow: View {
    let meal: SavedMeal
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                mealColor.opacity(0.3),
                                mealColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: mealIcon)
                    .font(.title3)
                    .foregroundColor(mealColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(meal.recipeName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(mealColor)
                            .frame(width: 6, height: 6)
                        Text(meal.mealType)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(mealColor)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(meal.prepTime)m")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar")
                            .font(.caption2)
                        Text(meal.difficulty)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.trailing, 8)
            
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
    }
    
    private var mealIcon: String {
        switch meal.mealType {
        case "Breakfast": return "sunrise.fill"
        case "Lunch": return "sun.max.fill"
        case "Dinner": return "moon.stars.fill"
        default: return "fork.knife"
        }
    }
    
    private var mealColor: Color {
        switch meal.mealType {
        case "Breakfast": return .orange
        case "Lunch": return .yellow
        case "Dinner": return .purple
        default: return .pink
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
