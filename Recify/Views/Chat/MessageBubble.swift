//
//  MessageBubble.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isFromCurrentUser {
                if let imageURL = message.senderImage {
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
                            Text(message.senderName.prefix(1))
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .padding(12)
                        .background(message.isFromCurrentUser ? Color.blue.opacity(0.2) : Color.pink.opacity(0.2))
                        .foregroundColor(message.isFromCurrentUser ? .blue : .pink.opacity(0.8))
                        .cornerRadius(16)
                }
                
                if let imageURL = message.imageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 200, height: 150)
                            .overlay(ProgressView())
                    }
                    .cornerRadius(12)
                }
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if message.isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: message.isFromCurrentUser ? .trailing : .leading)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            MessageBubble(message: Message(
                conversationId: "test",
                text: "Hey there! Ready to cook?",
                timestamp: Timestamp(date: Date()),
                senderId: "other",
                senderName: "Alexanne"
            ))
            
            MessageBubble(message: Message(
                conversationId: "test",
                text: "Yes! What should we make?",
                timestamp: Timestamp(date: Date()),
                senderId: "currentUser",  
                senderName: "Me"
            ))
        }
        .padding()
    }
}
