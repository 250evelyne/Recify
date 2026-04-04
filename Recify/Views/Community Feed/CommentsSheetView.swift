//
//  CommentsSheetView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct CommentsSheetView: View {
    let post: Post
    @ObservedObject var feedVM: FeedViewModel
    
    @State private var text : String = ""
    
    @Environment(\.dismiss) private var dissmiss
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack{
            
            HStack{
                Button {
                    dissmiss() //close the page, see if it works
                } label: {
                    Image(systemName: "xmark")
                }
                Spacer()
                Text("Comments")
                    .bold()
                    .font(.title)
                Spacer()
            }.padding()
            
            Divider()
            
            ScrollView{
                VStack(alignment: .leading){
                    
                    ForEach(feedVM.currentComments){ comment in
                        
                        HStack{
                            Image(authManager.userProfile?.avatar ?? "tomatoAvatar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .shadow(radius: 1)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading){
                                HStack{
                                    Text(comment.userName)
                                        .fontWeight(.semibold)
                                    Text(RelativeDateTimeFormatter().localizedString(for: comment.createdAt ,relativeTo: Date()))
                                        .foregroundStyle(.gray)
                                }
                                
                                Text("\(comment.text)")
                                
                            }
                            
                        }.padding(.top, 25)
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading) // i need this or else the .leaading in the vstack dosnt do anything by its self
                
            }
            
            Divider()
            
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 50)
                .foregroundStyle(.gray.opacity(0.05))
                .shadow(color: .gray, radius: 5)
                .overlay {
                    HStack{
                        Image(post.userAvatar ?? "tomatoAvatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 1)
                            .font(.title)
                        
                        TextField("Add a comment...", text: $text)
                        
                        Button {
                            if let postId = post.id, !text.isEmpty {
                                feedVM.addComment(to: postId, text: text)
                                text = ""
                            }
                        } label: {
                            Image(systemName: "paperplane.circle.fill")
                                .foregroundStyle(.pink)
                                .font(.title)
                        }
                        
                    }.padding()
                }
            
        }.padding()
            .onAppear {
                if let postId = post.id {
                    feedVM.fetchComments(for: postId)
                }
            }
        
    }
}

#Preview {
    CommentsSheetView(
        post: Post(id: "001", userId: "001", userName: "Jane", caption: "Test", imageUrl: "", createdAt: Date(), likes: 0),
        feedVM: FeedViewModel()
    )
}
