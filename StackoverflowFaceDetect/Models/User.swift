//
//  User.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//


struct User: Identifiable, Codable {
    let id: Int
    let displayName: String
    let reputation: Int
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case displayName = "display_name"
        case reputation
        case profileImage = "profile_image"
    }
}
