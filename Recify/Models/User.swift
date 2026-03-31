//
//  User.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var userName: String
    var favorites: [String]
    var avatar: String
    
    init(id: String? = nil, email: String, userName: String, favorites: [String] = [], avatar: String = "cookieAvatar") {
        self.id = id
        self.email = email
        self.userName = userName
        self.favorites = favorites
        self.avatar = avatar
    }
}
