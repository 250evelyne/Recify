//
//  savedCollectionsView.swift
//  Recify
//
//  Created by Macbook on 2026-03-10.
//

import SwiftUI

struct savedCollectionsView: View {
    //for the lazy v grid
    @ObservedObject var firebaseManager = FirebaseViewModel.shared
    
    let colums = [GridItem(.flexible()), GridItem(.flexible())]
    
//    @Environment(\.dismiss) var dissmiss
    
    @State private var showAlert : Bool = false
    @State private var selectedCollection : RecipeCollection?
    @State private var navigatingCollection: RecipeCollection?
    @State private var showCreateSheet = false
    @State private var isNavigating: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                if firebaseManager.userFavCollections.isEmpty && firebaseManager.savedRecipes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tap the heart icon on any recipe to save it here for later!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: colums, spacing: 20) {
                        NavigationLink(destination: FavoriteRecipesView(
                            collectionTitle: "Liked Recipes"
                        )) {
                            VStack(alignment: .leading) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 170, height: 170)
                                    
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }
                                
                                Text("Liked Recipes")
                                    .bold()
                                    .foregroundColor(.primary)
                                
                                Text("\(firebaseManager.savedRecipes.count) recipes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(firebaseManager.userFavCollections) { collection in
                            VStack {
                                saveFolderView(
                                    imageurl: collection.imageUrl,
                                    countRecipes: collection.recipeIds.count,
                                    name: collection.name,
                                    recipes: collection.recipeIds,
                                    isDeleting: selectedCollection?.id == collection.id
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedCollection?.id == collection.id {
                                    selectedCollection = nil
                                } else {
                                    navigatingCollection = collection
                                    isNavigating = true
                                }
                            }
                            .onLongPressGesture {
                                selectedCollection = collection
                                showAlert = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationDestination(isPresented: $isNavigating) {
            if let collection = navigatingCollection {
                FavoriteRecipesView(
                    collectionTitle: collection.name
                )
            }
        }
        .alert("Delete Collection?", isPresented: $showAlert) {
            Button("Delete", role: .destructive) {
                if let collection = selectedCollection {
                    withAnimation {
                        firebaseManager.deleteCollection(collection)
                    }
                    selectedCollection = nil
                }
            }
            Button("Cancel", role: .cancel) {
                selectedCollection = nil
            }
        } message: {
            if let name = selectedCollection?.name {
                Text("Are you sure you want to delete '\(name)'? This action cannot be undone.")
            }
        }
        .navigationTitle("Saved Collections")
        .navigationBarTitleDisplayMode(.large)
        //.navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .padding(10)
                        .foregroundStyle(.pink)
                        .bold()
                }
            }
        }
        .onAppear {
            firebaseManager.fecthUsersCollections()
        }
        .sheet(isPresented: $showCreateSheet) {
            NavigationStack {
                CreateCollection()
            }
        }
    }
       
}


struct saveFolderView : View {
    var imageurl : String
    var countRecipes : Int
    var name : String
    var recipes : [String]
    var isDeleting: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: imageurl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 170, height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isDeleting ? Color.red : Color.clear, lineWidth: 4)
                                .shadow(color: isDeleting ? .red : .clear, radius: 10)
                        )
                        .scaleEffect(isDeleting ? 0.95 : 1.0)
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                @unknown default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isDeleting)
            .overlay(alignment: .topTrailing) {
                Text("\(countRecipes) ITEMS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(8)
            }
            
            Text(name)
                .bold()
                .foregroundColor(isDeleting ? .red : .primary)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
    }
}

struct savedCollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            savedCollectionsView()
        }
    }
}
