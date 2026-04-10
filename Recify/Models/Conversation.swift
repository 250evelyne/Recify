//
//  ConversationRow.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import Foundation
import FirebaseFirestore

struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var participantNames: [String: String]
    var participantImages: [String: String]
    var lastMessage: String?
    var lastMessageTime: Timestamp?
    var unreadCount: [String: Int]
    
    init(id: String? = nil,
         participants: [String],
         participantNames: [String : String],
         participantImages: [String : String],
         lastMessage: String? = nil,
         lastMessageTime: Timestamp? = nil,
         unreadCount: [String : Int]) {
        //self.id = id
        self.participants = participants
        self.participantNames = participantNames
        self.participantImages = participantImages
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.unreadCount = unreadCount
    }
    
    func otherUserName(currentUserId: String) -> String {
        let otherUserId = participants.first { $0 != currentUserId } ?? ""
        return participantNames[otherUserId] ?? "Unknown"
    }
    
    func otherUserImage(currentUserId: String) -> String? {
        let otherUserId = participants.first { $0 != currentUserId } ?? ""
        return participantImages[otherUserId]
    }
    
    func otherUserId(currentUserId: String) -> String {
        return participants.first { $0 != currentUserId } ?? ""
    }
    
    var formattedTime: String {
        guard let timestamp = lastMessageTime else { return "" }
        let date = timestamp.dateValue()
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}
