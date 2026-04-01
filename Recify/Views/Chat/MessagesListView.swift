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
                                .background(Color.pink)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredConversations) { conversation in
                            NavigationLink(destination: ChatView(conversation: conversation)
                                .environmentObject(chatManager)) {
                                ConversationRow(conversation: conversation)
                            }
                        }
                        .onDelete(perform: deleteConversations)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {}) {
//                        Image(systemName: "gearshape.fill")
//                            .foregroundColor(.pink)
//                    }
//                }
                
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

struct MessagesListView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesListView()
    }
}
