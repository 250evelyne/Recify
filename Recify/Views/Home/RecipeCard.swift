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
        VStack(alignment: .leading, spacing: 8) {
            
         
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) //fills the box without squishing
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 140) //all images will be exactly 140pt tall
                .clipped()
                .cornerRadius(12)
                
                // Optional Pantry Match Badge
                if let match = matchPercentage {
                    Text("\(match)% Match")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                    .lineLimit(2) //prevents titles from wrapping endlessly
                    .multilineTextAlignment(.leading)
              
                    .frame(minHeight: 44, alignment: .topLeading)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 4)
        }
        //will forces the card to push everything to the top, so rows stay perfectly even
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct RecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            RecipeCard(title: "Short Title", imageURL: "", time: "20m", difficulty: "Easy", rating: 4.5, matchPercentage: 90)
            RecipeCard(title: "A Very Long Recipe Title That Wraps to Two Lines", imageURL: "", time: "45m", difficulty: "Hard", rating: 4.8, matchPercentage: nil)
        }
        .padding()
    }
}
