//
//  ChatViewWrapper.swift
//  Recify
//
//  Created by netblen on 12-04-2026.
//

import SwiftUI
import FirebaseAuth

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
        .onChange(of: chatManager.conversations) { conversations in
            if let conv = conversation,
               let updated = conversations.first(where: { $0.id == conv.id }) {
                conversation = updated
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
        
        chatManager.createConversation(
            withUserId: userId,
            userName: user.userName ?? "New User",
            userImage: user.avatar ?? "tomatoAvatar"
        ) { conversationId in
            guard let conversationId = conversationId else {
                isLoading = false
                return
            }
            
            let currentUID = Auth.auth().currentUser?.uid ?? ""
            
            if let found = chatManager.conversations.first(where: { $0.id == conversationId }) {
                conversation = found
                isLoading = false
                return
            }
            
            let currentUserName = AuthManager.shared.userProfile?.userName ?? "Me"
            let currentUserAvatar = AuthManager.shared.userProfile?.avatar ?? "tomatoAvatar"
            let requestText = "\(currentUserName) wants to chat with you!"
            
            let tempConversation = Conversation(
                id: conversationId,
                participants: [currentUID, userId],
                participantNames: [
                    currentUID: currentUserName,
                    userId: user.userName ?? "New User"
                ],
                participantImages: [
                    currentUID: currentUserAvatar,
                    userId: user.avatar ?? "tomatoAvatar"
                ],
                lastMessage: requestText,
                lastMessageTime: nil,
                unreadCount: [currentUID: 0, userId: 1],
                status: .pending,
                requestSenderId: currentUID
            )
            conversation = tempConversation
            isLoading = false
        }
    }
}
