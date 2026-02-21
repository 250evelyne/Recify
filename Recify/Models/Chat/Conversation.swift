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
