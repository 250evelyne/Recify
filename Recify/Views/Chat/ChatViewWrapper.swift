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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let foundConversation = chatManager.conversations.first(where: { $0.id == conversationId }) {
                    conversation = foundConversation
                } else {
                    let currentUID = Auth.auth().currentUser?.uid ?? ""
                    let tempConversation = Conversation(
                        id: conversationId,
                        participants: [currentUID, userId],
                        participantNames: [
                            currentUID: AuthManager.shared.userProfile?.userName ?? "Me",
                            userId: user.userName ?? "New User"
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
