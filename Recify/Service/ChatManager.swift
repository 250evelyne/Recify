//
//  ChatManager.swift
//  Recify
//
//  Created by netblen on 2026-02-11.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreData

class ChatManager: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var currentConversation: Conversation?
    @Published var userCache: [String: User] = [:]
    
    private let db = Firestore.firestore()
    private var conversationsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    
    // Mandatary Core Data context
    private let viewContext = PersistenceController.shared.container.viewContext
    
    init() {
        startListeningToConversations()
    }
    
    deinit {
        conversationsListener?.remove()
        messagesListener?.remove()
    }
    
    static func getLiveAvatar(for userId: String) -> String? {
        return shared.userCache[userId]?.avatar
    }
    
    static let shared = ChatManager()
    
    
    func startListeningToConversations() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        conversationsListener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "lastMessageTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self?.conversations = documents.compactMap { doc -> Conversation? in
                    try? doc.data(as: Conversation.self)
                }
            }
    }
    
    func startListeningToMessages(conversationId: String) {
        messagesListener?.remove()
        
        //what we have offline from Core Data for speed
        self.loadOfflineMessages(for: conversationId)
        
        //then, listen for live updates from Firebase
        messagesListener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let firebaseMessages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                self?.messages = firebaseMessages
                
                self?.cacheMessagesLocally(firebaseMessages)
            }
    }
    
    // MARK: - Core Data Persistence Logic
    private func cacheMessagesLocally(_ firebaseMessages: [Message]) {
        viewContext.perform {
            for msg in firebaseMessages {
                let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", msg.id ?? "")
                
                if let count = try? self.viewContext.count(for: request), count == 0 {
                    let entity = MessageEntity(context: self.viewContext)
                    entity.id = msg.id
                    entity.text = msg.text
                    entity.senderName = msg.senderName
                    entity.senderId = msg.senderId
                    entity.timestamp = msg.timestamp.dateValue()
                    entity.conversationId = msg.conversationId
                }
            }
            
            do {
                try self.viewContext.save()
            } catch {
                print("Core Data Save Error: \(error)")
            }
        }
    }
    
    func loadOfflineMessages(for conversationId: String) {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MessageEntity.timestamp, ascending: true)]
        
        do {
            let localEntities = try viewContext.fetch(request)
            self.messages = localEntities.map { entity in
                Message(
                    id: entity.id,
                    conversationId: entity.conversationId ?? "",
                    text: entity.text ?? "",
                    imageURL: nil,
                    timestamp: Timestamp(date: entity.timestamp ?? Date()),
                    senderId: entity.senderId ?? "",
                    senderName: entity.senderName ?? "Unknown",
                    senderImage: nil
                )
            }
        } catch {
            print("Failed to fetch offline messages: \(error)")
        }
    }

    
    // MARK: - Actions
    func sendMessage(text: String, in conversationId: String) {
        guard let currentUser = AuthManager.shared.userProfile else { return }
        
        let currentUserName = AuthManager.shared.userProfile?.userName ?? "Me"
        let currentAvatar = AuthManager.shared.userProfile?.avatar ?? "tomatoAvatar"
        
        let messageId = UUID().uuidString
        let newMessage = Message(
            conversationId: conversationId,
            text: text,
            timestamp: Timestamp(date: Date()),
            senderId: Auth.auth().currentUser?.uid ?? "",
            senderName: AuthManager.shared.userProfile?.userName ?? "Me",
            senderImage: AuthManager.shared.userProfile?.avatar 
        )
        
        do {
            try db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(messageId)
                .setData(from: newMessage)
            
            db.collection("conversations").document(conversationId).updateData([
                "lastMessage": text,
                "lastMessageTime": Timestamp(date: Date())
            ])
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    func deleteConversation(_ conversation: Conversation) {
        guard let id = conversation.id else { return }
        
        db.collection("conversations").document(id).delete()
        
        let request: NSFetchRequest<NSFetchRequestResult> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "conversationId == %@", id)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting local cache: \(error)")
        }
    }
    
    // MARK: - Conversation Management
    func createConversation(withUserId otherUserId: String, userName: String, userImage: String?, completion: @escaping (String?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        let existing = conversations.first { conv in
            conv.participants.contains(otherUserId) && conv.participants.count == 2
        }
        
        if let existingId = existing?.id {
            completion(existingId)
            return
        }
        
        let docRef = db.collection("conversations").document()
        let conversationId = docRef.documentID
        
        let currentUserName = AuthManager.shared.userProfile?.userName ?? "Me"
        
        let newConversation = Conversation(
            participants: [currentUserId, otherUserId],
            participantNames: [
                currentUserId: currentUserName, 
                otherUserId: userName
            ],
            participantImages: [
                otherUserId: userImage ?? "tomatoAvatar"
            ],
            lastMessage: "Started a new conversation",
            lastMessageTime: Timestamp(date: Date()),
            unreadCount: [currentUserId: 0, otherUserId: 0]
        )
        
        do {
            try docRef.setData(from: newConversation)
            completion(conversationId)
        } catch {
            print("Error creating conversation: \(error)")
            completion(nil)
        }
    }
    
    func signOut() {
        self.conversations = []
        self.messages = []
        self.currentConversation = nil
        conversationsListener?.remove()
        messagesListener?.remove()
    }
    
    func listenToOtherUser(userId: String) {
        db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data() else {
                print("DEBUG: No data for \(userId)")
                return
            }
            let updatedUser = User(
                id: userId,
                email: data["email"] as? String ?? "",
                userName: data["userName"] as? String ?? "",
                avatar: data["avatar"] as? String ?? "tomatoAvatar"
            )
            DispatchQueue.main.async {
                self.userCache[userId] = updatedUser
            }
        }
    }
    
    
}
