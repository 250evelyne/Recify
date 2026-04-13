//
//  MessagesListView.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import SwiftUI
import FirebaseAuth

struct MessagesListView: View {
    @StateObject private var chatManager = ChatManager.shared
    @State private var selectedTab: MessageTab = .allChats
    @State private var showNewChat: Bool = false
    @State private var searchText: String = ""
    
    enum MessageTab: String, CaseIterable {
        case allChats = "Chats"
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
                        if tab == .requests {
                            let count = pendingRequestCount
                            Text(count > 0 ? "Requests (\(count))" : "Requests").tag(tab)
                        } else {
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if filteredConversations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: selectedTab == .requests ? "envelope.badge" : "bubble.left.and.bubble.right")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))
                        Text(selectedTab == .requests ? "No message requests" : "No conversations yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(selectedTab == .requests ? "When someone sends you a message request, it will appear here." : "Start chatting with other cooks!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if selectedTab != .requests {
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredConversations) { conversation in
                            NavigationLink(destination: ChatView(conversation: conversation)
                                .environmentObject(chatManager)) {
                                    ConversationRow(conversation: conversation)
                                        .environmentObject(chatManager)
                                }
                        }
                        .onDelete(perform: deleteConversations)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                chatManager.startListeningToConversations()
            }
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
    
    var pendingRequestCount: Int {
        let currentId = Auth.auth().currentUser?.uid ?? ""
        return chatManager.conversations.filter { conversation in
            conversation.status == .pending &&
            conversation.requestSenderId != currentId
        }.count
    }
    
    var filteredConversations: [Conversation] {
        let currentId = Auth.auth().currentUser?.uid ?? ""
        let baseConversations: [Conversation]
        
        switch selectedTab {
        case .allChats:
            baseConversations = chatManager.conversations.filter { $0.status == .accepted }
        case .requests:
            baseConversations = chatManager.conversations.filter { conversation in
                conversation.status == .pending &&
                conversation.requestSenderId != currentId
            }
       
        }
        
        if searchText.isEmpty {
            return baseConversations
        } else {
            return baseConversations.filter {
                $0.otherUserName(currentUserId: currentId)
                    .lowercased()
                    .contains(searchText.lowercased())
            }
        }
    }
    
    func deleteConversations(offsets: IndexSet) {
        offsets.map { filteredConversations[$0] }.forEach { conversation in
            chatManager.deleteConversation(conversation)
        }
    }
}
