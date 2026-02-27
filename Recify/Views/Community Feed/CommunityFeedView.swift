//
//  CommunityFeedView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct CommunityFeedView: View {
    @State private var selectedTab : Int = 0
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.fill") //TODO: change this to the user pfp
                            .clipShape(.circle)
                            .font(.title)
                    }
                    Spacer()
                    Text("Community Feed")
                        .bold()
                    Spacer()
                    Circle() //TODO: need to make a page for the creation of a post
                        .shadow(color: .pink, radius: 3, y: 2)
                        .foregroundColor(.pink)
                        .frame(width: 50, height: 50)
                        .overlay {
                            NavigationLink(destination: CreatePostView())
                            {
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .font(.title)
                            }
                        }
                }
                .padding()
                .background(.blue.opacity(0.2))
                
                HStack{
                    tabView(index: 0, title: "Trending", selectedTab: $selectedTab)
                    tabView(index: 1, title: "Following", selectedTab: $selectedTab)
                    
                    Spacer()
                }.padding(.horizontal)
                    .padding(.top)
                
                Divider()
                
                ScrollView(.vertical, showsIndicators: false){
                    //ForEach //fecth all the psots in the firebase
                    PostView(posts: Post(userId: "user_012", caption: "nfew wnife ewjde esejfesj eses k jdjsefjewf", imageUrl: "https://picsum.photos/400", createdAt: Date(), likes: 46), comments: mockComments)
                    PostView(posts: Post(userId: "user_012", caption: "nfew wnife ewjde esejfesj eses k jdjsefjewf", imageUrl: "https://picsum.photos/400", createdAt: Date(), likes: 46), comments: mockComments)
                }
            }.background(Color.pink.opacity(0.1))
        }
    }
}

#Preview {
    CommunityFeedView()
}
