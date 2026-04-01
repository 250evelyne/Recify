//
//  CommunityFeedView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct CommunityFeedView: View {
    @StateObject private var feedVM = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    NavigationLink(destination: MyPostsView()) {
                        Image(systemName: "person.fill")
                            .clipShape(.circle)
                            .font(.title)
                    }
                    Spacer()
                    Text("Community Feed")
                        .bold()
                    Spacer()
                    Circle()
                        .shadow(color: .pink, radius: 3, y: 2)
                        .foregroundColor(.pink)
                        .frame(width: 50, height: 50)
                        .overlay {
                            NavigationLink(destination: CreatePostView()) {
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .font(.title)
                            }
                        }
                }
                .padding()
                .background(.blue.opacity(0.08))
                
                            
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(feedVM.posts) { post in
                        PostView(post: post, feedVM: feedVM)
                    }
                }
            }
            .background(Color.pink.opacity(0.1))
            .onAppear {
                feedVM.fetchPosts() //tjis loads posts when the view appears
            }
        }
    }
}


#Preview {
    CommunityFeedView()
}
