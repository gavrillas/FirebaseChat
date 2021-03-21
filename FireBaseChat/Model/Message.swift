//
//  Message.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import FirebaseFirestore

public struct Message: Codable {
    let chatID: String
    let sender: String
    let body: String
    let date: Double
    
    enum CodingKeys: String, CodingKey {
        case chatID = "chat"
        case sender
        case body
        case date
    }
}
