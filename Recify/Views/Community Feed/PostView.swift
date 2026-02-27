//
//  PostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

let mockComments: [Comment] = [
    Comment(
        id: "c1",
        userId: "user_002",
        text: "This looks amazing 🔥",
        createdAt: Date()
    ), Comment(
        id: "c2",
        userId: "user_003",
        text: "Definitely trying this tonight!",
        createdAt: Date().addingTimeInterval(-3600)
    ), Comment(
        id: "c3",
        userId: "user_004",
        text: "Can I replace the cheese with something else?",
        createdAt: Date().addingTimeInterval(-7200)
    )

]

let mockPosts: [Post] = [
    Post(
        id: "post_001",
        userId: "user_001",
        caption: "Creamy garlic pasta with spinach 😍🍝",
        imageUrl: "https://picsum.photos/400",
        createdAt: Date().addingTimeInterval(-86400),
        likes: 42
    ),
    Post(
        id: "post_002",
        userId: "user_003",
        caption: "First try at sour dough bread",
        imageUrl: "https://picsum.photos/400",
        createdAt: Date().addingTimeInterval(-862340),
        likes: 29
    )
]


struct PostView: View {
    let posts : Post
    let comments : [Comment]
    
    @State private var showComments : Bool = false
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
                .frame(width: 380)

            VStack(alignment: .leading)
            {
                HStack(spacing: 15){
                    Image(systemName: "person.fill") //TODO: change this to the user pfp
                        .clipShape(.circle) .font(.title)
                    VStack(alignment: .leading){
                        
                        Text("chef_amy") //TODO: get the user name fromt he user is
                            .bold()
                        Text(RelativeDateTimeFormatter().localizedString(for: posts.createdAt, relativeTo: Date())) //i dont think we need location so ya
                            .foregroundStyle(.secondary)
                    }
                }.padding(.leading)
                
                HStack{
                    Spacer()
                    AsyncImage(url: URL(string: posts.imageUrl)){ phase in
                        switch phase{
                        case .empty:
                            ProfileView()
                        case .success(let image) :
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 350, maxHeight: 400)
                                .clipped()
                                .cornerRadius(10)
                        case .failure(_) :
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
                
                Text(posts.caption)
                    .font(.title2)
                    .padding(.leading)
                
                HStack{
                    Button {
                        //TODO:adds 1 like to the posts like count
                    } label: {
                        interactionBtn(icon: "heart.fill", count: 124, color: .pink)
                    }

//                    NavigationLink {
//                        CommentsSheetView(comments: comments)
//                    } label: {
//                        interactionBtn(icon: "bubble.fill", count: 124, color: .blue) //i dont think we gonna do share
//                    }
//                    
                    Button {
                        showComments = true
                    } label: {
                        interactionBtn(icon: "bubble.fill", count: 124, color: .blue) //i dont think we gonna do share
                    }


                }.padding(.leading)
            }
            .sheet(isPresented: $showComments) {
                CommentsSheetView(comments: mockComments)
            }
            .padding()
        }.frame(width: 400, height: 550)
            
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
            }
    }
}

#Preview { PostView(posts: Post(userId: "001", caption: "Delicious home made sourdough", imageUrl: "https://picsum.photos/400", createdAt: Date(), likes: 0), comments: mockComments)
}
