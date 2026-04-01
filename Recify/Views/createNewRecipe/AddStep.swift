//
//  AddStep.swift
//  Recify
//
//  Created by Macbook on 2026-03-27.
//

import SwiftUI

struct AddStep: View {
    var onAdd: (String) -> Void = { _ in }
    
    @Environment(\.dismiss) private var dismiss
    
    var stepCount : Int
    @State private var instruction: String = ""
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Divider()
                
                HStack{
                    Circle()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.blue.opacity(0.3))
                        .overlay {
                            Text("\(stepCount)")
                                .bold()
                                .font(.system(size: 20))
                        }
                    Text("DEFINING THE NEXT ACTION")
                        .foregroundStyle(.black.opacity(0.5))
                        .font(.system(size: 13))
                        .bold()
                }.padding(.top)
                
                Text("Instruction")
                    .foregroundStyle(.black.opacity(0.6))
                    .font(.system(size: 17))
                    .bold()
                    .padding(.top, 30)
                
                TextField(
                    "Preheat oven to 375F and prepare your baking sheet...",
                    text: $instruction,
                    axis: .vertical
                )
                .font(.title3)
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                
                HStack{
                    Spacer()
                    Button {
                        onAdd(instruction)
                        print("selected instruction: \(instruction)")
                        dismiss()
                    } label: {
                        Label("Save Step", systemImage: "checkmark.circle.fill")
                            .padding(.init(top: 10, leading: 60, bottom: 10, trailing: 60))
                    }.font(.title3)
                        .disabled(instruction.isEmpty)
                        .buttonStyle(.bordered)
                        .tint(.pink)
                    Spacer()
                }
                
                Spacer()
                
            }.padding()
                .padding(.horizontal)
                .navigationTitle("Add Step")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }.buttonStyle(.bordered)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onAdd(instruction)
                            dismiss()
                        } label: {
                            Text("Save")
                        }
                        .buttonStyle(.bordered)
                        .disabled(instruction.isEmpty)
                    }
                }
        }//nav end
    }
}

#Preview {
    AddStep(stepCount: 2)
}
