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
    private let db = Firestore.firestore()
    
    // Listen for real-time post updates
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
    
    // Save a new post to Firestore
    func createPost(caption: String, imageUrl: String) {
        print("Attempting to create post...")
        
        // 1. Get the current authenticated user ID directly from Firebase Auth
        guard let authUser = Auth.auth().currentUser else {
            print("❌ ERROR: No user logged into Firebase Auth!")
            return
        }
        
        let userId = authUser.uid
        
        // 2. Fetch the user's document from Firestore to get their username safely
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ ERROR fetching user profile: \(error.localizedDescription)")
                return
            }
            
            // Extract the userName (Fallback to "Unknown User" just in case)
            let userName = document?.data()?["userName"] as? String ?? "Unknown User"
            
            print("✅ User found: \(userName). Preparing to save...")
            
            // 3. Create and save the post
            let newPost = Post(
                userId: userId,
                userName: userName,
                caption: caption,
                imageUrl: imageUrl,
                createdAt: Date(),
                likes: 0
            )
            
            do {
                _ = try self.db.collection("posts").addDocument(from: newPost)
                print("✅ SUCCESS: Post successfully added to Firestore!")
            } catch {
                print("❌ Firebase Error creating post: \(error.localizedDescription)")
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
    
    
}
