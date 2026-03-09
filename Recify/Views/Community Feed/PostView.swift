//
//  PostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct PostView: View {
    let post: Post
    @ObservedObject var feedVM: FeedViewModel // Passed down from CommunityFeedView
    
    @State private var showComments: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
                .frame(width: 380)
            
            VStack(alignment: .leading) {
                HStack(spacing: 15) {
                    Image(systemName: "person.fill")
                        .clipShape(.circle)
                        .font(.title)
                    VStack(alignment: .leading) {
                        // Dynamically display the user's name
                        Text(post.userName)
                            .bold()
                        Text(RelativeDateTimeFormatter().localizedString(for: post.createdAt, relativeTo: Date()))
                            .foregroundStyle(.secondary)
                    }
                }.padding(.leading)
                
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: post.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 350, maxHeight: 400)
                                .clipped()
                                .cornerRadius(10)
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 400)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    Spacer()
                }
                
                Text(post.caption)
                    .font(.title2)
                    .padding(.leading)
                
                HStack {
                    Button {
                        // Adds 1 like to the post in Firestore
                        feedVM.likePost(post: post)
                    } label: {
                        interactionBtn(icon: "heart.fill", count: post.likes, color: .pink)
                    }
                    
                    Button {
                        showComments = true
                    } label: {
                        interactionBtn(icon: "bubble.fill", count: 0, color: .blue)
                    }
                    
                }.padding(.leading)
            }
            .sheet(isPresented: $showComments) {
                CommentsSheetView(comments: []) // Pass empty array until Comments fetch is wired up
            }
            .padding()
        }
    }
    
    // MARK: - Helper Views
    
    // Re-added the missing interactionBtn view builder
    @ViewBuilder
    private func interactionBtn(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Preview

#Preview {
    PostView(
        post: Post(
            userId: "001",
            userName: "N/A",
            caption: "Delicious home made sourdough",
            imageUrl: "https://picsum.photos/400",
            createdAt: Date(),
            likes: 12
        ),
        feedVM: FeedViewModel()
    )
}
