//
//  CreatePostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct CreatePostView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var caption : String = ""
    
    var body: some View {
        VStack{
            
            HStack{
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel").foregroundStyle(.gray)
                }
                Spacer()
                Text("Create Post").bold().font(.title)
                Spacer()
                Button {
                    //TODO: save the post to the db
                } label: {
                    Text("Post")
                }.buttonStyle(.borderedProminent)
                    .tint(.pink)

            }.padding()

            Divider()
            
            Button {
                //TODO: add fnction to add a photo
            } label: {
                
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                    .foregroundStyle(.blue.opacity(0.1))
                    .frame(height: 300)
                    .padding()
                    .overlay {
                        VStack{
                            
                            Image(systemName: "camera.on.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
//                                .clipShape(.circle)
                                .foregroundStyle(.blue)
                            Text("Add Photo")
                                .foregroundStyle(.blue)
                                .bold()
                        }
                    }
            }
            
            TextField("Wrtie a caption...", text: $caption).padding()
            
            Spacer()
            
            
        }.navigationBarBackButtonHidden(true)
        
    }
}

#Preview {
    CreatePostView()
}
