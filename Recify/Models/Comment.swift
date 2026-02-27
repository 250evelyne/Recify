//
//  Comment.swift
//  Recify
//
//  Created by Macbook on 2026-02-26.
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    var id: String?
    let userId: String
    let text: String
    let createdAt: Date
}
