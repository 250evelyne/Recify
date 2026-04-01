//
//  MyPostsView.swift
//  Recify
//
//  Created by netblen on 04-03-2026.
//

import SwiftUI
import FirebaseAuth

struct MyPostsView: View {
    @StateObject private var feedVM = FeedViewModel()
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if feedVM.userPosts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No posts yet")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.gray)
                    Text("When you share recipes, they will appear here.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 100)
            } else {
                ForEach(feedVM.userPosts) { post in
                    PostView(post: post, feedVM: feedVM)
                }
            }
        }
        .navigationTitle("My Posts")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.pink.opacity(0.05))
        .onAppear {
            if let uid = currentUserId {
                feedVM.fetchUserPosts(userId: uid)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyPostsView()
    }
}
