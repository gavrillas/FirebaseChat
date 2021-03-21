//
//  Chat.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 07..
//

import FirebaseFirestoreSwift

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let participants: [String]
    let lastUpdate: Double
    let lastMessage: Message?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case participants
        case lastUpdate
        case lastMessage
    }
}
