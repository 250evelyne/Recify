//
//  searchResultCard.swift
//  Recify
//
//  Created by Macbook on 2026-03-08.
//

import SwiftUI

struct searchResultCard: View {
    let title: String
    let imageURL: String
    let time: Int
    let difficulty: String
    @State var isFavorite : Bool = true //TODO:fecth from firebase if the recipi is in thier favories
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 360, height: 340)
            .overlay {
                
                
                VStack(alignment: .leading, spacing: 0) {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.gray)
                            )
                    }
                    .overlay(alignment: .topTrailing){
                        
                        Button {
                            //TODO: add to favoties
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: "suit.heart.fill")
                                .foregroundStyle(isFavorite ? .pink : .gray)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                        }
                        .padding(10)
                        .padding(.trailing, 20)
                    }
                    .frame(width: 330, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 20) {
                            Label("\(time) mins", systemImage: "clock.fill")
                                .font(.subheadline)
                                .foregroundStyle(.black.opacity(0.6))

                            Label(difficulty, systemImage: "chart.bar.fill")
                                .font(.subheadline)
                                .foregroundStyle(.black.opacity(0.6))
                        }
                        
                        
                    }
                    .padding(10)
                }
                
            }
            .foregroundStyle(Color.white)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding()
    }
}

#Preview {
    searchResultCard(
        title: "Zesty Avocado Quinoa",
        imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
        time: 25,
        difficulty: "Easy"
    )
}
