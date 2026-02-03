//
//  User.swift
//  Recify
//
//  Created by mac on 2026-02-02.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var userName: String
    var favorites: [String]
    
    init(id: String? = nil, email: String, userName: String, favorites: [String] = []) {
        self.id = id
        self.email = email
        self.userName = userName
        self.favorites = favorites
    }
}
