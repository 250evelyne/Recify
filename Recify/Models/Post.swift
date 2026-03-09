//
//  Post.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var userName: String 
    var caption: String
    var imageUrl: String
    var createdAt: Date
    var likes: Int
    var commentCount: Int = 0
}
