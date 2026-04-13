//
//  NewChatView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NewChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var chatManager: ChatManager
    
    @State private var searchText: String = ""
    @State private var users: [User] = []
    @State private var isLoading: Bool = false
    @State private var isCreatingConversation: Bool = false
    @State private var lastDocument: DocumentSnapshot? = nil
    @State private var canLoadMore: Bool = true
    
    private let pageSize = 15
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search users...", text: $searchText)
                            .onChange(of: searchText) { newValue in
                                if newValue.isEmpty {
                                    resetPagination()
                                    loadAllUsers()
                                } else {
                                    searchUsers()
                                }
                            }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    if users.isEmpty && !isLoading {
                        emptyStateView
                    } else {
                        List {
                            ForEach(users) { user in
                                NavigationLink(destination: ChatViewWrapper(user: user)
                                    .environmentObject(chatManager)) {
                                        UserRow(user: user)
                                    }
                                    .onAppear {
                                        if user.id == users.last?.id && canLoadMore && searchText.isEmpty {
                                            loadAllUsers()
                                        }
                                    }
                            }
                            
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                if isCreatingConversation {
                    loadingOverlay
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                if users.isEmpty {
                    loadAllUsers()
                }
            }
        }
    }
    
    // MARK: - Logic
    func resetPagination() {
        users = []
        lastDocument = nil
        canLoadMore = true
    }
    
    func loadAllUsers() {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        var query = db.collection("users")
            .order(by: "userName")
            .limit(to: pageSize)
        
        if let lastCursor = lastDocument {
            query = query.start(afterDocument: lastCursor)
        }
        
        query.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("DEBUG: Firestore Error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.lastDocument = documents.last
                
                let newUsers = documents.compactMap { doc -> User? in
                    guard let user = try? doc.data(as: User.self), user.id != currentUserId else { return nil }
                    
                    if self.users.contains(where: { $0.id == user.id }) {
                        return nil
                    }
                    return user
                }
                
                self.users.append(contentsOf: newUsers)
                self.canLoadMore = documents.count == self.pageSize
            }
        }
    }
    
    func searchUsers() {
        guard !searchText.isEmpty else {
            resetPagination()
            loadAllUsers()
            return
        }
        
        isLoading = true
        db.collection("users").limit(to: 50).getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let documents = snapshot?.documents {
                    let currentUserId = Auth.auth().currentUser?.uid
                    let allFetched = documents.compactMap { try? $0.data(as: User.self) }
                    
                    let filtered = allFetched.filter {
                        $0.id != currentUserId &&
                        (($0.userName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                         $0.email.lowercased().contains(searchText.lowercased()))
                    }
                    
                    self.users = filtered.sorted { ($0.userName ?? "") < ($1.userName ?? "") }
                }

            }
        }
    }
    
    // MARK: - Helper Views
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "person.2" : "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            Text(searchText.isEmpty ? "No other users yet" : "No users found")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .pink))
        }
    }
}

struct UserRow: View {
    let user: User
    var body: some View {
        HStack(spacing: 12) {
            Image(user.avatar ?? "tomatoAvatar")
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.userName ?? "New User")
                    .font(.headline)
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
            .environmentObject(ChatManager())
    }
}
