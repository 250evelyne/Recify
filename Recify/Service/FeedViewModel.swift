//
//  FeedViewModel.swift
//  Recify
//
//  Created by netblen on 03-03-2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userPosts: [Post] = []
    @Published var currentComments: [Comment] = []
    @Published var recipes: [Recipe] = []

    
    private var commentsListener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    func fetchPosts() {
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.posts = documents.compactMap { try? $0.data(as: Post.self) }
            }
    }
    
    func createPost(caption: String, imageUrl: String) {
        print("Attempting to create post...")
        
        guard let authUser = Auth.auth().currentUser else {
            print("ERROR: No user logged into Firebase Auth!")
            return
        }
        
        let userId = authUser.uid
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("ERROR fetching user profile: \(error.localizedDescription)")
                return
            }
            
            let userName = document?.data()?["userName"] as? String ?? "Unknown User"
            
            let userAvatar = document?.data()?["avatar"] as? String ?? "cupcakeAvatar"
            
            print("User found: \(userName). Preparing to save...")
            
            let newPost = Post(
                userId: userId,
                userName: userName,
                userAvatar: userAvatar,
                caption: caption,
                imageUrl: imageUrl,
                createdAt: Date(),
                likes: 0
            )
            
            do {
                _ = try self.db.collection("posts").addDocument(from: newPost)
                print("SUCCESS: Post successfully added to Firestore!")
            } catch {
                print("Firebase Error creating post: \(error.localizedDescription)")
            }
        }
    }
    
    
    // Increment the like count
    func likePost(post: Post) {
        guard let postId = post.id else { return }
        db.collection("posts").document(postId).updateData([
            "likes": FieldValue.increment(Int64(1))
        ])
    }
    
    
    
    // Fetch posts for a specific user
    func fetchUserPosts(userId: String) {
        db.collection("posts")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching user posts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var fetchedPosts = documents.compactMap { try? $0.data(as: Post.self) }
                fetchedPosts.sort { $0.createdAt > $1.createdAt }
                
                self.userPosts = fetchedPosts
            }
    }
    
    
    // Fetch live comments for a specific post
    func fetchComments(for postId: String) {
        commentsListener?.remove()
        
        commentsListener = db.collection("posts").document(postId).collection("comments")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching comments: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.currentComments = documents.compactMap { try? $0.data(as: Comment.self) }
            }
    }
    
    func addComment(to postId: String, text: String) {
        guard let authUser = Auth.auth().currentUser else { return }
        let userId = authUser.uid
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            let userName = document?.data()?["userName"] as? String ?? "Unknown User"
            
            let newComment = Comment(
                userId: userId,
                userName: userName,
                text: text,
                createdAt: Date()
            )
            
            do {
                _ = try self.db.collection("posts").document(postId).collection("comments").addDocument(from: newComment)
                
                self.db.collection("posts").document(postId).updateData([
                    "commentCount": FieldValue.increment(Int64(1))
                ])
                
                print("SUCCESS: Comment added and count incremented!")
            } catch {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }
}
