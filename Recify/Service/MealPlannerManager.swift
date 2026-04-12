//
//  MealPlannerManager.swift
//  Recify
//
//  Created by mac on 2026-04-11.
//

import Foundation

class MealPlannerManager {
    static let shared = MealPlannerManager()
    
    private let savedMealsKey = "savedMeals"
    private let todaysMealKey = "todaysMeal"
    
    private let defaults = UserDefaults.standard

    
    private init() {}
    
    func saveMeal(_ meal: SavedMeal) {
        var meals = getAllMeals()
        meals.append(meal)
        
        if let encoded = try? JSONEncoder().encode(meals) {
            defaults.set(encoded, forKey: savedMealsKey)
            defaults.synchronize()
            print(" Saved meal: \(meal.recipeName) for \(meal.date)")
        }
        
        updateTodaysMeal()
    }
    
    func getAllMeals() -> [SavedMeal] {
        guard let data = defaults.data(forKey: savedMealsKey) else {
            print(" No meals in storage")
            return []
        }
        
        if let meals = try? JSONDecoder().decode([SavedMeal].self, from: data) {
            print(" Loaded \(meals.count) meals from storage")
            return meals
        }
        
        return []
    }
    
    func getMeals(for date: Date) -> [SavedMeal] {
        let allMeals = getAllMeals()
        let calendar = Calendar.current
        
        let filtered = allMeals.filter { meal in
            calendar.isDate(meal.date, inSameDayAs: date)
        }
        
        print(" Found \(filtered.count) meals for date: \(date)")
        return filtered
    }
    
    func getTodaysMeal() -> SavedMeal? {
        let allMeals = getAllMeals()
        print("Total meals in storage: \(allMeals.count)")
        
        let today = Date()
        let todaysMeals = getMeals(for: today)
        
        print("🔍 Meals for today: \(todaysMeals.count)")
        
        if let dinnerMeal = todaysMeals.first(where: { $0.mealType == "Dinner" }) {
            print(" Returning Dinner: \(dinnerMeal.recipeName)")
            return dinnerMeal
        } else if let lunchMeal = todaysMeals.first(where: { $0.mealType == "Lunch" }) {
            print(" Returning Lunch: \(lunchMeal.recipeName)")
            return lunchMeal
        } else if let breakfast = todaysMeals.first {
            print(" Returning Breakfast: \(breakfast.recipeName)")
            return breakfast
        }
        
        print(" No meals found for today")
        return nil
    }
    
    func deleteMeal(id: UUID) {
        var meals = getAllMeals()
        meals.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(meals) {
            defaults.set(encoded, forKey: savedMealsKey)
            defaults.synchronize()
        }
        
        updateTodaysMeal()
    }
    
    func hasPlannedMeal(for date: Date) -> Bool {
        !getMeals(for: date).isEmpty
    }
    
    private func updateTodaysMeal() {
        if let todaysMeal = getTodaysMeal(),
           let encoded = try? JSONEncoder().encode(todaysMeal) {
            defaults.set(encoded, forKey: todaysMealKey)
            defaults.synchronize()
        } else {
            defaults.removeObject(forKey: todaysMealKey)
            defaults.synchronize()
        }
    }
}
