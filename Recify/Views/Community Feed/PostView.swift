//
//  PostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI
import FirebaseAuth

struct PostView: View {
    let post: Post
    @ObservedObject var feedVM: FeedViewModel
    
    @State private var showComments: Bool = false
    @State private var isLiked : Bool = false
    
    @State private var showEditSheet: Bool = false
    @State private var editedCaption: String = ""
    
    private var isMyPost: Bool {
        Auth.auth().currentUser?.uid == post.userId
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
                .frame(width: 380)
            
            VStack(alignment: .leading) {
                HStack(spacing: 15) {
                    let avatarName = post.userAvatar
                    Image((avatarName == nil || avatarName!.isEmpty) ? "tomatoAvatar" : avatarName!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                    VStack(alignment: .leading) {
                        Text(post.userName)
                            .bold()
                        Text(RelativeDateTimeFormatter().localizedString(for: post.createdAt, relativeTo: Date()))
                            .foregroundStyle(.secondary)
                    }
                    
                 
                    if isMyPost {
                        Spacer()
                        Menu {
                            Button {
                                editedCaption = post.caption
                                showEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                if let id = post.id {
                                    feedVM.deletePost(postId: id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .padding(10)
                                .foregroundStyle(.gray)
                        }
                    }
                }.padding(.leading)
                
                Spacer()
                
                HStack {
                    Spacer()
                    if let uiImage = decodeBase64(post.imageUrl) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 350, maxHeight: 400)
                            .clipped()
                            .cornerRadius(10)
                    } else {
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
                    }
                    Spacer()
                }
                
                Text(post.caption)
                    .font(.title2)
                    .padding(.leading)
                
                HStack {
                    Button {
                        feedVM.likePost(post: post)
                        if !isLiked {
                            isLiked = true
                        }
                    } label: {
                        interactionBtn(
                            icon: "heart.fill",
                            count: post.likes,
                            color: isLiked ? .pink : .gray // Changes color when liked
                        )
                    }
                    .disabled(isLiked)
                    
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
            .sheet(isPresented: $showEditSheet) {
                NavigationStack {
                    Form {
                        TextField("Caption", text: $editedCaption)
                    }
                    .navigationTitle("Edit Post")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if let id = post.id {
                                    feedVM.updatePost(postId: id, newCaption: editedCaption)
                                }
                                showEditSheet = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showEditSheet = false }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .padding()
        }
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
}

func decodeBase64(_ base64String: String) -> UIImage? {
    guard let data = Data(base64Encoded: base64String) else { return nil }
    return UIImage(data: data)
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
