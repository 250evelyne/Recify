//
//  ChatView.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @EnvironmentObject var chatManager: ChatManager
    let conversation: Conversation
    
    @State private var messageText: String = ""
    @State private var showImagePicker: Bool = false
    
    var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatManager.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .id(chatManager.userCache.values.compactMap { $0.avatar }.joined())
                    .padding(.vertical)
                }
                .onChange(of: chatManager.messages) { messages in
                    for message in messages {
                        if message.senderId != currentUserId {
                            chatManager.listenToOtherUser(userId: message.senderId)
                        }
                    }
                }
                .onAppear {
                    if let conversationId = conversation.id {
                        chatManager.startListeningToMessages(conversationId: conversationId)
                        
                        for participantId in conversation.participants {
                            if participantId != currentUserId {
                                chatManager.listenToOtherUser(userId: participantId)
                            }
                        }
                        
                        if let lastMessage = chatManager.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
//                Button(action: {
//                    showImagePicker = true
//                }) {
//                    Image(systemName: "camera.fill")
//                        .foregroundColor(.white)
//                        .frame(width: 36, height: 36)
//                        .background(Color.pink)
//                        .clipShape(Circle())
//                }
                
                HStack {
                    TextField("Message \(conversation.otherUserName(currentUserId: currentUserId))...", text: $messageText)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    
//                    Button(action: {}) {
//                        Image(systemName: "face.smiling")
//                            .foregroundColor(.gray)
//                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(messageText.isEmpty ? Color.gray : Color.pink)
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .navigationTitle(conversation.otherUserName(currentUserId: currentUserId))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    let otherUserId = conversation.participants.first(where: { $0 != currentUserId }) ?? ""
                    let liveFriendImage = chatManager.userCache[otherUserId]?.avatar ?? conversation.otherUserImage(currentUserId: currentUserId)
                    
                    UserAvatarView(
                        avatarName: liveFriendImage,
                        name: conversation.otherUserName(currentUserId: currentUserId)
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(conversation.otherUserName(currentUserId: currentUserId))
                            .font(.headline)
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty,
              let conversationId = conversation.id else { return }
        
        chatManager.sendMessage(text: messageText, in: conversationId)
        messageText = ""
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(conversation: Conversation(
                participants: ["user1", "user2"],
                participantNames: ["user1": "Me", "user2": "Alexanne"],
                participantImages: [:],
                unreadCount: ["user1": 0, "user2": 0]
            ))
            .environmentObject(ChatManager())
        }
    }
}
