//
//  MessageRepository.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 08..
//

import class RxSwift.PublishSubject

protocol MessageUseCase {
    func listenLastMessage(for chat: Chat, message: PublishSubject<Message>)
    func add(data: Message)
    func listenChanges(dataSubject: PublishSubject<[Message]>, orderBy field: String?, descending: Bool, where filter: FirebaseFilter?, limit: Int?)
}

struct MessageRepository: FirebaseUseCase, MessageUseCase {
    typealias Data = Message
    
    let collectionName = "messages"
    
    func listenLastMessage(for chat: Chat, message: PublishSubject<Message>) {
        guard let chatID = chat.id else { return }
        db.collection(collectionName)
            .whereField("chat", isEqualTo: chatID)
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                let datas = documents.compactMap {document -> Data? in
                    try? document.data(as: Data.self)
                }
                guard let lastMessage = datas.first else { return }
                message.onNext(lastMessage)
            }
    }
}
