//
//  CalendarView.swift
//  Recify
//
//  Created by mac on 2026-03-07.
//

import SwiftUI

struct CalendarView: View { //
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedMeal: String = "Lunch"
    
    let meals = ["Breakfast", "Lunch", "Dinner"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Calendar
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .background(Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.3))
                .cornerRadius(16)
                
                // Meal Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Meal")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(meals, id: \.self) { meal in
                            Button(action: {
                                selectedMeal = meal
                            }) {
                                Text(meal)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedMeal == meal ? .white : .black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(selectedMeal == meal ? Color.green : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Add Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Add to Planner")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Add to Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
