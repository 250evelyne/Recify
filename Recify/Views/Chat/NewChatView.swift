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
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search users...", text: $searchText)
                            .onChange(of: searchText) { _ in
                                searchUsers()
                            }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if users.isEmpty && !searchText.isEmpty {
                        Text("No users found")
                            .foregroundColor(.gray)
                            .padding()
                    } else if users.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2")
                                .font(.system(size: 64))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No other users yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Create another account to test messaging!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        //                        List(users) { user in
                        //                            NavigationLink(destination: ChatViewWrapper(user: user)
                        //                                .environmentObject(chatManager)) {
                        //                                HStack(spacing: 12) {
                        //                                    Circle()
                        //                                        .fill(Color.pink.opacity(0.3))
                        //                                        .frame(width: 48, height: 48)
                        //                                        .overlay(
                        //                                            Text(user.userName.prefix(1).uppercased())
                        //                                                .font(.title3)
                        //                                                .foregroundColor(.white)
                        //                                        )
                        //
                        //                                    VStack(alignment: .leading, spacing: 4) {
                        //                                        Text(user.userName)
                        //                                            .font(.headline)
                        //                                            .foregroundColor(.primary)
                        //                                        Text(user.email)
                        //                                            .font(.caption)
                        //                                            .foregroundColor(.gray)
                        //                                    }
                        //
                        //                                    Spacer()
                        //                                }
                        //                                .padding(.vertical, 8)
                        //                            }
                        //                        }
                        //                        .listStyle(PlainListStyle())
                        
                        
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(users) { user in
                                    NavigationLink(destination: ChatViewWrapper(user: user)
                                        .environmentObject(chatManager)) {
                                            UserCard(user: user)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
            
        
                }
                
                if isCreatingConversation {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                }
            }
            .recifyBackground()
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
            .onAppear {
                loadAllUsers()
            }
        }
    }
    
    func loadAllUsers() {
        isLoading = true
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        db.collection("users")
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error loading users: \(error.localizedDescription)")
                    return
                }
                
                users = snapshot?.documents.compactMap { doc in
                    let user = try? doc.data(as: User.self)
                    return user?.id != currentUserId ? user : nil
                } ?? []
                
                print("Loaded \(users.count) users")
            }
    }
    
    func searchUsers() {
        guard !searchText.isEmpty else {
            loadAllUsers()
            return
        }
        
        isLoading = true
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        db.collection("users")
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error searching users: \(error.localizedDescription)")
                    return
                }
                
                let allUsers = snapshot?.documents.compactMap { doc -> User? in
                    let user = try? doc.data(as: User.self)
                    return user?.id != currentUserId ? user : nil
                } ?? []
                
                users = allUsers.filter { user in
                    user.userName.lowercased().contains(searchText.lowercased()) ||
                    user.email.lowercased().contains(searchText.lowercased())
                }
            }
    }
}


struct UserCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 16) {
            let avatarName = user.avatar.isEmpty ? "tomatoAvatar" : user.avatar
            
            Image(avatarName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.userName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}



struct ChatViewWrapper: View {
    let user: User
    @EnvironmentObject var chatManager: ChatManager
    @State private var conversation: Conversation?
    @State private var isLoading: Bool = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Starting conversation...")
                        .foregroundColor(.gray)
                }
            } else if let conversation = conversation {
                ChatView(conversation: conversation)
                    .environmentObject(chatManager)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Failed to create conversation")
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            createOrFindConversation()
        }
    }
    
    func createOrFindConversation() {
        guard let userId = user.id else {
            isLoading = false
            return
        }
        
        print("Creating/finding conversation with \(user.userName)")
        
        chatManager.createConversation(
            withUserId: userId,
            userName: user.userName,
            userImage: user.avatar //chnage this from nil to this
        ) { conversationId in
            print("Conversation ID: \(conversationId ?? "nil")")
            
            guard let conversationId = conversationId else {
                print("Failed to create conversation")
                isLoading = false
                return
            }
            
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let foundConversation = chatManager.conversations.first(where: { $0.id == conversationId }) {
                    print("Found conversation in list")
                    conversation = foundConversation
                } else {
                    print("Conversation not found in list, creating temporary one")
                    // Create a temporary conversation object
                    let tempConversation = Conversation(
                        id: conversationId,
                        participants: [Auth.auth().currentUser?.uid ?? "", userId],
                        participantNames: [
                            Auth.auth().currentUser?.uid ?? "": AuthManager.shared.userProfile?.userName ?? "Me",
                            userId: user.userName
                        ],
                        participantImages: [:],
                        lastMessage: nil,
                        lastMessageTime: nil,
                        unreadCount: [:]
                    )
                    conversation = tempConversation
                }
                isLoading = false
            }
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
            .environmentObject(ChatManager())
    }
}
