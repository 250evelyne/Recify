//
//  CreatePostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption: String = ""
    
    // Create an instance of the ViewModel to save the post
    @StateObject private var feedVM = FeedViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel").foregroundStyle(.gray)
                }
                Spacer()
                Text("Create Post").bold().font(.title)
                Spacer()
                Button {
                    // Save the post to the DB
                    feedVM.createPost(caption: caption, imageUrl: "https://picsum.photos/400")
                    dismiss() // Close the view
                } label: {
                    Text("Post")
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(caption.isEmpty) // Prevent empty posts
            }
            .padding()
            
            Divider()
            
            Button {
                // TODO: Add image picker later
            } label: {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                    .foregroundStyle(.blue.opacity(0.1))
                    .frame(height: 300)
                    .padding()
                    .overlay {
                        VStack {
                            Image(systemName: "camera.on.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(.blue)
                            Text("Add Photo")
                                .foregroundStyle(.blue)
                                .bold()
                        }
                    }
            }
            
            TextField("Write a caption...", text: $caption)
                .padding()
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CreatePostView()
}
