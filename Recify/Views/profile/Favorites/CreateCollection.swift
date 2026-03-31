//
//  CreateCollection.swift
//  Recify
//
//  Created by Macbook on 2026-03-19.
//

import SwiftUI

struct CreateCollection: View {
    
    @Environment(\.dismiss) var dismiss
//    @ObservedObject var viewModel : FirebaseViewModel
    
    @State private var collectionName : String = ""
    @State private var httpChosen : String = ""

    
    let cols = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        VStack(alignment: .leading){
            
            Text("COLLECTION NAME")
                .foregroundStyle(.gray)
                .font(.system(size: 13))
            
            GroupBox{
                Section {
                    TextField("e.g. Sunday Brunch", text: $collectionName)
                }
            }.padding(.bottom)
                
            Text("CHOSE A COVER")
                .foregroundStyle(.gray)
                .font(.system(size: 13))
            
            
            ScrollView(showsIndicators: false) {
            
                LazyVGrid(columns: cols) {
                    Button {
                        httpChosen = "https://plus.unsplash.com/premium_photo-1672199330043-d6d2690229e9?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://plus.unsplash.com/premium_photo-1672199330043-d6d2690229e9?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Dinner",
                            isSelected: httpChosen == "https://plus.unsplash.com/premium_photo-1672199330043-d6d2690229e9?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://images.unsplash.com/photo-1608897013039-887f21d8c804?q=80&w=992&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://images.unsplash.com/photo-1608897013039-887f21d8c804?q=80&w=992&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Lunch",
                            isSelected: httpChosen == "https://images.unsplash.com/photo-1608897013039-887f21d8c804?q=80&w=992&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://plus.unsplash.com/premium_photo-1676106623583-e68dd66683e3?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://plus.unsplash.com/premium_photo-1676106623583-e68dd66683e3?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Breakfast",
                            isSelected: httpChosen == "https://plus.unsplash.com/premium_photo-1676106623583-e68dd66683e3?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Desserts",
                            isSelected: httpChosen == "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Healthy",
                            isSelected: httpChosen == "https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://images.unsplash.com/photo-1497534446932-c925b458314e?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://images.unsplash.com/photo-1497534446932-c925b458314e?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Drinks",
                            isSelected: httpChosen == "https://images.unsplash.com/photo-1497534446932-c925b458314e?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://images.unsplash.com/photo-1734775088232-652b2eecbbc7?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    } label: {
                        coverView(
                            cover: "https://images.unsplash.com/photo-1734775088232-652b2eecbbc7?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            name: "Quick Bites",
                            isSelected: httpChosen == "https://images.unsplash.com/photo-1734775088232-652b2eecbbc7?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        )
                    }
                    Button {
                        httpChosen = "https://picsum.photos/400"
                    } label: {
                        coverView(
                            cover: "https://picsum.photos/400",
                            name: "Other",
                            isSelected: httpChosen == "https://picsum.photos/400"
                        )
                    }
                    
                } //TODO: make it visible when use clicks 1 image
            }
            
            
            
            
            Spacer()
            
        }.padding()
            .navigationBarBackButtonHidden(true)
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveAction()
                    } label: {
                        Text("Create")
                    }.disabled(collectionName.isEmpty || httpChosen.isEmpty)
                }
                
            }//toolvar
    }
    
    private func saveAction(){
        guard !collectionName.isEmpty else {return}
        
        FirebaseViewModel.shared.saveNewCollection(name: collectionName, imageUrl: httpChosen)
        
        dismiss()
    }
}


struct coverView : View {

    var cover : String
    var name : String
    var isSelected: Bool
    
    var body: some View {
        
        VStack {
            AsyncImage(url: URL(string: cover)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Color.red.opacity(0.1) // Show error state
                } else {
                    ProgressView()
                }
            }
            .frame(width: 160, height: 160) // Fixed size for the container
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 4)
            )
            .overlay(alignment: .bottomLeading, content: {
                Text(name)
                    .padding(5)
                    .foregroundStyle(.black)
                    .fontWeight(.semibold)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            })
        }
        .animation(.easeInOut, value: isSelected)
    }
}

#Preview {
    CreateCollection()
}
