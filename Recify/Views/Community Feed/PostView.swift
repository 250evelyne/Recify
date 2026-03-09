//
//  PostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct PostView: View {
    let post: Post
    @ObservedObject var feedVM: FeedViewModel
    
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
                        // Dynamically display the users name
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
                        //relpaced 0 with post.commentCount so it will count the real comments
                        interactionBtn(icon: "bubble.fill", count: post.commentCount, color: .blue)
                    }
                    
                }.padding(.leading)
            }
            .sheet(isPresented: $showComments) {
                CommentsSheetView(post: post, feedVM: feedVM)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Views
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

struct interactionBtn : View {
    var icon : String
    var count : Int
    var color : Color
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(color, lineWidth: 1)
        //.foregroundStyle(color.opacity(0.3)) //so aparently its stroke or the abckground color no inbetween
            .frame(width: 80, height: 40)
            .overlay {
                HStack{
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    
                    Text("\(count)") .foregroundStyle(color)
                }
            }.background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
            likes: 12,
            commentCount: 5 
        ),
        feedVM: FeedViewModel()
    )
}
