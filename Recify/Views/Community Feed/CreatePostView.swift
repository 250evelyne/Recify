//
//  CreatePostView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption: String = ""
    @ObservedObject var feedVM: FeedViewModel
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var base64String: String = ""
    
    @State private var showSuccessAlert = false
    @State private var isPosting = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.pink)
                }
                Spacer()
                Text("Create Post").bold().font(.title)
                Spacer()
                
                Button {
                    isPosting = true
                    if !base64String.isEmpty {
                        feedVM.createPost(caption: caption, imageUrl: base64String)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSuccessAlert = true
                            isPosting = false
                        }
                    }
                } label: {
                    if isPosting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Post")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(caption.isEmpty || base64String.isEmpty)
            }
            .padding()
            
            Divider()
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [10,6]))
                        .foregroundStyle(.blue.opacity(0.1))
                        .frame(width: 350,height: 300)
                        .overlay {
                            VStack {
                                Image(systemName: "camera.fill")
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
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                        if let compressedData = uiImage.jpegData(compressionQuality: 0.5) {
                            self.base64String = compressedData.base64EncodedString()
                        }
                    }
                }
            }
            
            TextField("Write a caption...", text: $caption)
                .padding()
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your recipe has been shared with the community!")
        }
    }
}

#Preview {
    CreatePostView(feedVM: FeedViewModel())
}
