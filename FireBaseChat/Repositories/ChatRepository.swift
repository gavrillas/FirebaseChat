//
//  ChatRepository.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 08..
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import class RxSwift.PublishSubject

protocol ChatUseCase {
    func add(data: Chat)
    func listenChanges(dataSubject: PublishSubject<[Chat]>, orderBy field: String?, descending: Bool, where filter: FirebaseFilter?, limit: Int?)
    func update(data: Chat)
}

struct ChatRepository: FirebaseUseCase, ChatUseCase {
    typealias Data = Chat
    
    let collectionName = "chats"
    
    func update(data: Chat) {
        let chat = Chat(id: data.id,
                        title: data.title,
                        participants: data.participants,
                        lastUpdate: Date().timeIntervalSince1970,
                        lastMessage: data.lastMessage)
        guard let id = chat.id else { return }
        do {
            try db.collection(collectionName).document(id).setData(from: chat)
        }
        catch {
            print(error)
        }
    }
}
