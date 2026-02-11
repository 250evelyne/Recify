import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ChatManager: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var currentConversation: Conversation?
    
    private let db = Firestore.firestore()
    private var conversationsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    
    init() {
        startListeningToConversations()
    }
    
    deinit {
        conversationsListener?.remove()
        messagesListener?.remove()
    }
    
    func startListeningToConversations() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        conversationsListener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "lastMessageTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching conversations: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                self?.conversations = documents.compactMap { doc -> Conversation? in
                    try? doc.data(as: Conversation.self)
                }
            }
    }
    
    func startListeningToMessages(conversationId: String) {
        messagesListener?.remove()
        
        messagesListener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                self?.messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
            }
    }
    
    func sendMessage(text: String, imageURL: String? = nil, in conversationId: String) {
        guard let currentUser = Auth.auth().currentUser,
              let userProfile = AuthManager.shared.userProfile else { return }
        
        let message = Message(
            conversationId: conversationId,
            text: text,
            imageURL: imageURL,
            timestamp: Timestamp(date: Date()),
            senderId: currentUser.uid,
            senderName: userProfile.userName,
            senderImage: nil
        )
        
        do {
            let _ = try db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .addDocument(from: message)
            
            db.collection("conversations").document(conversationId).updateData([
                "lastMessage": text,
                "lastMessageTime": Timestamp(date: Date())
            ])
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    func createConversation(withUserId: String, userName: String, userImage: String?, completion: @escaping (String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser,
              let currentUserProfile = AuthManager.shared.userProfile else {
            completion(nil)
            return
        }
        
        let participants = [currentUser.uid, withUserId].sorted()
        
        db.collection("conversations")
            .whereField("participants", isEqualTo: participants)
            .getDocuments { [weak self] snapshot, error in
                if let existingConversation = snapshot?.documents.first {
                    completion(existingConversation.documentID)
                    return
                }
                
                var participantNames: [String: String] = [:]
                participantNames[currentUser.uid] = currentUserProfile.userName
                participantNames[withUserId] = userName
                
                var participantImages: [String: String] = [:]
                if let userImage = userImage {
                    participantImages[withUserId] = userImage
                }
                
                var unreadCount: [String: Int] = [:]
                unreadCount[currentUser.uid] = 0
                unreadCount[withUserId] = 0
                
                let conversation = Conversation(
                    participants: participants,
                    participantNames: participantNames,
                    participantImages: participantImages,
                    lastMessage: nil,
                    lastMessageTime: nil,
                    unreadCount: unreadCount
                )
                
                do {
                    let docRef = try self?.db.collection("conversations").addDocument(from: conversation)
                    completion(docRef?.documentID)
                } catch {
                    print("Error creating conversation: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
    
    func deleteConversation(_ conversation: Conversation) {
        guard let id = conversation.id else { return }
        
        db.collection("conversations").document(id).delete { error in
            if let error = error {
                print("Error deleting conversation: \(error.localizedDescription)")
            }
        }
    }
}
