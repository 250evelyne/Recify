//
//  User.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var email: String
    var userName: String?
    var favorites: [String]?
    var avatar: String?
    var createdAt: Date?
    var mealsCooked: Int?
    
    init(id: String? = nil, email: String, userName: String? = nil, favorites: [String]? = [], avatar: String? = "tomatoAvatar", createdAt: Date? = nil, mealsCooked: Int? = 0) {
        self.id = id
        self.email = email
        self.userName = userName
        self.favorites = favorites
        self.avatar = avatar
        self.createdAt = createdAt
        self.mealsCooked = mealsCooked 
    }
}
