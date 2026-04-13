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

    @ObservedObject var authManager = AuthManager.shared
    @EnvironmentObject var chatManager: ChatManager

    var isFromCurrentUser: Bool {
        return message.senderId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        
        let liveAvatar = chatManager.userCache[message.senderId]?.avatar
        
        
        HStack(alignment: .bottom, spacing: 8) {
            if !isFromCurrentUser {
                let liveAvatar = chatManager.userCache[message.senderId]?.avatar
                
                UserAvatarView(
                    avatarName: liveAvatar ?? message.senderImage,
                    name: message.senderName
                )
            } else {
                Spacer(minLength: 50)
                
                let liveAvatar = authManager.userProfile?.avatar ?? "tomatoAvatar"
                
                UserAvatarView(
                    avatarName: authManager.userProfile?.avatar,
                    name: authManager.userProfile?.userName ?? "Me"
                )
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
                
                Text(message.formattedTime)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: isFromCurrentUser ? .trailing : .leading)
    }
}

struct UserAvatarView: View {
    let avatarName: String?
    let name: String
    
    var body: some View {
        let imageName = (avatarName == nil || avatarName!.isEmpty) ? "tomatoAvatar" : avatarName!
        
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.2))
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
