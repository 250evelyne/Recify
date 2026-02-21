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
                    .padding(.vertical)
                }
                .onChange(of: chatManager.messages.count) { _ in
                    if let lastMessage = chatManager.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastMessage = chatManager.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.pink)
                        .clipShape(Circle())
                }
                
                HStack {
                    TextField("Message \(conversation.otherUserName(currentUserId: currentUserId))...", text: $messageText)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    
                    Button(action: {}) {
                        Image(systemName: "face.smiling")
                            .foregroundColor(.gray)
                    }
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
                    if let imageURL = conversation.otherUserImage(currentUserId: currentUserId) {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.pink.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(conversation.otherUserName(currentUserId: currentUserId).prefix(1))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(conversation.otherUserName(currentUserId: currentUserId))
                            .font(.headline)
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "video.fill")
                    }
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        .onAppear {
            if let conversationId = conversation.id {
                chatManager.startListeningToMessages(conversationId: conversationId)
                chatManager.currentConversation = conversation
            }
        }
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty,
              let conversationId = conversation.id else { return }
        
        // Use 'chatManager' (no $) and call the correct 'in:' parameter
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
