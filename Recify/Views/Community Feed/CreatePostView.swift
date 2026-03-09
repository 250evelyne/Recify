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
                    feedVM.createPost(caption: caption, imageUrl: "https://picsum.photos/400")
                    dismiss() 
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
                    .strokeBorder(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                    .foregroundStyle(.blue.opacity(0.1))
                    .frame(width: 350,height: 300)
                    
                    .overlay {
                        VStack {
                            Image(systemName: "camera.fill") //TODO: ask for permission like the locaiton permission, then we get the path where the image is stored and then u store it in the firebase
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundStyle(.blue)
                                .padding(15)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                )

                            Text("Add Photo")
                                .foregroundStyle(.blue)
                                .bold()
                        }
                    }
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
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
