//
//  User.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 07..
//

import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    let email: String
    let nickname: String?
    let age: Int?
    let picture: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nickname
        case age
        case picture
    }
}
