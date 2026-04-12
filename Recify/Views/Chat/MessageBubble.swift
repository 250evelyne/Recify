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
    
    var isFromCurrentUser: Bool {
        return message.senderId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !isFromCurrentUser {
                UserAvatarView(imageURL: message.senderImage, name: message.senderName)
            } else {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isFromCurrentUser ? Color.blue.opacity(0.8) : Color.gray.opacity(0.15))
                        .foregroundColor(isFromCurrentUser ? .white : .primary)
                        .cornerRadius(18, corners: isFromCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                }
                
                // Show images if they exist
                if let imageURL = message.imageURL, !imageURL.isEmpty {
                    MessageImageView(url: imageURL)
                }
                
                Text(message.formattedTime)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            // Your messages are pushed to the right
            if isFromCurrentUser {
                // No avatar for current user in WhatsApp style
            } else {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: isFromCurrentUser ? .trailing : .leading)
    }
}

struct UserAvatarView: View { //TODO: chnage so the default like like gray so we know its loading and its not the actuall pfp, to fix the chat view and the mesaage view not laoding the user pfp
    let imageURL: String?
    let name: String
    
    var body: some View {
        let avatarName =  imageURL!.isEmpty ? "tomatoAvatar" : imageURL!
        
        Image(avatarName)
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .shadow(radius: 1)
    }
}

struct MessageImageView: View {
    let url: String
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(Color.gray.opacity(0.2))
                .overlay(ProgressView())
        }
        .frame(maxWidth: 240, maxHeight: 300)
        .cornerRadius(12)
    }
}

// MARK: - Helpers for WhatsApp Style Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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
