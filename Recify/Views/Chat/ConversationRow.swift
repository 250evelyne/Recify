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
    
    var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageURL = conversation.otherUserImage(currentUserId: currentUserId) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 18, y: 18)
                )
            } else {
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(conversation.otherUserName(currentUserId: currentUserId).prefix(1))
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 18, y: 18)
                    )
            }
            
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
    }
}

struct ConversationRow_Previews: PreviewProvider {
    static var previews: some View {
        ConversationRow(conversation: Conversation(
            participants: ["user1", "user2"],
            participantNames: ["user1": "Me", "user2": "Chef Julia"],
            participantImages: ["user2": "https://i.pravatar.cc/150?img=1"],
            lastMessage: "That sourdough starter worked perfectly!",
            lastMessageTime: Timestamp(date: Date()),
            unreadCount: ["user1": 2, "user2": 0]
        ))
        .padding()
    }
}
