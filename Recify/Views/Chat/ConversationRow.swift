//
//  ConversationRow.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ConversationRow: View {
    let conversation: Conversation
    
    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject var chatManager: ChatManager
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    var otherUserId: String {
        conversation.otherUserId(currentUserId: currentUserId)
    }
    
    var resolvedAvatar: String? {
        chatManager.userCache[otherUserId]?.avatar
        ?? conversation.otherUserImage(currentUserId: currentUserId)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(
                avatarName: resolvedAvatar,
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
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            chatManager.listenToOtherUser(userId: otherUserId)
        }
    }
}

struct ConversationRow_Previews: PreviewProvider {
    static var previews: some View {
        ConversationRow(conversation: Conversation(
            participants: ["user1", "user2"],
            participantNames: ["user1": "Me", "user2": "Chef Julia"],
            participantImages: ["user2": "tomatoAvatar"],
            lastMessage: "That sourdough starter worked perfectly!",
            lastMessageTime: Timestamp(date: Date()),
            unreadCount: ["user1": 2, "user2": 0]
        ))
        .environmentObject(ChatManager.shared)
        .padding()
    }
}
