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
    //let rating: Double
    let matchPercentage: Int?
    let recipe: Recipe?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Image Section
            ZStack(alignment: .topTrailing) {
                Group {
                    if imageURL.hasPrefix("http") {
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
                    } else {
                        let cleanString = imageURL.components(separatedBy: "base64,").last ?? imageURL
                        
                        if let imageData = Data(base64Encoded: cleanString, options: .ignoreUnknownCharacters),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.1))
                        }
                    }
                }
                .frame(height: 140)
                .clipped()
                .cornerRadius(12)
                
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
            
            // MARK: - Details Section
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        
                        Text(recipe != nil ? "\(recipe!.prepTime) min" : time)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar")
                        Text(recipe != nil ? recipe!.level : difficulty)
                    }
                    
                    if let calories = recipe?.calories {
                        HStack(spacing: 4) {
                            Image(systemName: "flame")
                            Text("\(calories) kcal")
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.top, 4)
            .padding(.horizontal, 4)
        }
        //will forces the card to push everything to the top, so rows stay perfectly even
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct RecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCard(
            title: "Classic Margherita Pizza",
            imageURL: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
            time: "20m",
            difficulty: "Easy",
            //rating: 4.5,
            matchPercentage: 90,
            recipe: nil 
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
