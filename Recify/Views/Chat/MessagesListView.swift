//
//  MessagesListView.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import SwiftUI
import FirebaseAuth

struct MessagesListView: View {
    @StateObject private var chatManager = ChatManager()
    
    @State private var selectedTab: MessageTab = .allChats
    @State private var showNewChat: Bool = false
    @State private var searchText: String = ""
    
    enum MessageTab: String, CaseIterable {
        case allChats = "All chats"
        case groups = "Groups"
        case requests = "Requests"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search any user", text: $searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                Picker("", selection: $selectedTab) {
                    ForEach(MessageTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                if filteredConversations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No conversations yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Start chatting with other cooks!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: { showNewChat = true }) {
                            Text("Start New Chat")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.pink, .pink.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                                .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredConversations) { conversation in
                                NavigationLink(destination: ChatView(conversation: conversation)
                                    .environmentObject(chatManager)) {
                                    ConversationCard(conversation: conversation)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .recifyBackground()
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewChat = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.pink)
                    }
                }
            }
            .sheet(isPresented: $showNewChat) {
                NewChatView()
                    .environmentObject(chatManager)
            }
        }
    }
    
    var filteredConversations: [Conversation] {
        let conversations: [Conversation]
        
        switch selectedTab {
        case .allChats:
            conversations = chatManager.conversations
        case .groups:
            conversations = []
        case .requests:
            conversations = []
        }
        
        if searchText.isEmpty {
            return conversations
        } else {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                return conversations
            }
            
            return conversations.filter { conversation in
                conversation.otherUserName(currentUserId: currentUserId)
                    .lowercased()
                    .contains(searchText.lowercased())
            }
        }
    }
    
    func deleteConversations(offsets: IndexSet) {
        offsets.map { chatManager.conversations[$0] }.forEach { conversation in
            chatManager.deleteConversation(conversation)
        }
    }
}

struct ConversationCard: View {
    let conversation: Conversation
    
    var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(
                imageURL: conversation.otherUserImage(currentUserId: currentUserId),
                name: conversation.otherUserName(currentUserId: currentUserId)
            )
            .frame(width: 56, height: 56)
            .overlay(
                Circle()
                    .fill(Color.green)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 18, y: 18)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.otherUserName(currentUserId: currentUserId))
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(conversation.formattedTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(conversation.lastMessage ?? "No messages yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let unreadCount = conversation.unreadCount[currentUserId], unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color.pink)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct MessagesListView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesListView()
    }
}
