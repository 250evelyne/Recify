//
//  RecipeCard.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct RecipeCard: View {
    let title: String
    let imageURL: String
    let time: String
    let difficulty: String
    let rating: Double
    let matchPercentage: Int?
    
    var body: some View {
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
            .frame(height: 140)
            .clipped()
            .overlay(
                VStack {
                    HStack {
                        if let match = matchPercentage {
                            Text("\(match)% Match")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(time)
                            .font(.caption2)
                    }
                    
                    Text("•")
                        .font(.caption2)
                    
                    Text(difficulty)
                        .font(.caption2)
                }
                .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct RecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCard(
            title: "Zesty Avocado Quinoa",
            imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
            time: "25m",
            difficulty: "Easy",
            rating: 4.7,
            matchPercentage: 90
        )
        .frame(width: 160)
        .padding()
    }
}
