//
//  CommentsSheetView.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import SwiftUI

struct CommentsSheetView: View {
    
    let comments : [Comment]

    @Environment(\.dismiss) private var dissmiss
    var body: some View {
        VStack{
            
            HStack{
                Button {
                    dissmiss() //clsoe the page, see if it works
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
                    
                    ForEach(comments){ comment in
                        
                        HStack{
                            
                            AsyncImage(url: URL(string: "comment.imageUrl")){ phase in //TODO: we need to go fecth the user pfp with the user id
                                switch phase{
                                case .empty:
                                    ProfileView()
                                case .success(let image) :
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 40, maxHeight: 40)
                                        .clipShape(.circle)
                                case .failure(_) :
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(.circle)
                                        .frame(height: 30)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            VStack(alignment: .leading){
                                HStack{
                                    Text("user name") //TODO: smae thing fecth the users name with the id
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
            
        }.padding()
        
    }
}

#Preview {
    CommentsSheetView(comments: [Comment(id: "001", userId: "001", text: "this recipe is amazing the pastle colors worked perfectly for my baby shower", createdAt: Date())])
}
