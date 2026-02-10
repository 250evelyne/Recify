import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var conversationId: String
    var text: String?
    var imageURL: String?
    var timestamp: Timestamp
    var senderId: String
    var senderName: String
    var senderImage: String?
    
    var date: Date {
        return timestamp.dateValue()
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var isFromCurrentUser: Bool {
        return senderId == AuthManager.shared.userProfile?.id
    }
    
    var bubbleColor: String {
        return isFromCurrentUser ? "blue" : "pink"
    }
}
