//
//  searchResultCard.swift
//  Recify
//
//  Created by Macbook on 2026-03-08.
//

import SwiftUI

struct searchResultCard: View {
    let mealId: String
    let title: String
    let imageURL: String
    let time: Int
    let difficulty: String
//    let difficulty: DifficultyLevel
    var height : CGFloat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .overlay(Image(systemName: "fork.knife").foregroundColor(.gray))
            }
            .frame(height: height ?? 140)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label("\(time) min", systemImage: "clock")
                    Label(difficulty, systemImage: "chart.bar")
                }
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            }
//            .padding(.top, 8)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
//        .background(Color.white)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding()
        .shadow(radius: 2, x:4, y:4)
       
        
    }
}

#Preview {
    searchResultCard(
        mealId: "52772",
        title: "Zesty Avocado Quinoa",
        imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
        time: 25,
//        difficulty: DifficultyLevel.easy
        difficulty: "Easy"
    )
}
