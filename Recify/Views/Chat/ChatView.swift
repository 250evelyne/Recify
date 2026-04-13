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
    
    var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }
    
    var isPendingRecipient: Bool {
        conversation.status == .pending && conversation.requestSenderId != currentUserId
    }
    
    var isPendingSender: Bool {
        conversation.status == .pending && conversation.requestSenderId == currentUserId
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatManager.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                if let id = conversation.id {
                    chatManager.startListeningToMessages(conversationId: id)
                    
                    chatManager.markConversationAsRead(conversationId: id)
                }
            }
            
            if isPendingRecipient {
                requestActionButtons
            } else {
                messageInputField
                if isPendingSender {
                    Text("Waiting for acceptance...")
                        .font(.caption).foregroundColor(.gray).padding(.bottom, 8)
                }
            }
        }
        //.navigationTitle(conversation.otherUserName(currentUserId: currentUserId))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    let otherId = conversation.otherUserId(currentUserId: currentUserId)
                    let liveAvatar = chatManager.userCache[otherId]?.avatar ?? conversation.otherUserImage(currentUserId: currentUserId)
                    let otherName = conversation.otherUserName(currentUserId: currentUserId)
                    
                    if let avatar = liveAvatar, !avatar.isEmpty {
                        Image(avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(String(otherName.prefix(1)).uppercased())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            )
                    }
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text(otherName)
                            .font(.headline)
                        
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Add your info button action here
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var requestActionButtons: some View {
        HStack(spacing: 16) {
            Button("Decline") { chatManager.declineRequest(conversation: conversation) }
                .foregroundColor(.red).frame(maxWidth: .infinity)
            Button("Accept") { chatManager.acceptRequest(conversation: conversation) }
                .padding().background(Color.pink).foregroundColor(.white).cornerRadius(10)
        }
        .padding()
    }
    
    private var messageInputField: some View {
        HStack {
            TextField("Message...", text: $messageText)
                .padding().background(Color.gray.opacity(0.1)).cornerRadius(20)
            Button(action: {
                chatManager.sendMessage(text: messageText, in: conversation.id ?? "")
                messageText = ""
            }) {
                Image(systemName: "paperplane.fill")
            }.disabled(messageText.isEmpty || isPendingSender) 
        }.padding()
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
