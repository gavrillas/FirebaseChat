//
//  ChatsViewModel.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 07..
//

import RxSwift
import RxDataSources
import struct RxCocoa.Driver

struct ChatsViewModel {
    struct SectionModel {
        let header: String
        var items: [ChatCellViewModel]
    }
    
    struct Input {
        let addNewChat: Observable<String>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let tableData: Driver<[SectionModel]>
        let newChat: Driver<Void>
        let openChat: Driver<Chat?>
    }
    
    private let _user: User
    private let _chats = PublishSubject<[Chat]>()
    private let _chatUseCase: ChatUseCase!
    private let _messageUseCase: MessageUseCase!
    
    init(user: User, chatUseCase: ChatUseCase, messageUseCase: MessageUseCase) {
        _user = user
        _chatUseCase = chatUseCase
        _messageUseCase = messageUseCase
        _chatUseCase.listenChanges(dataSubject: _chats, orderBy: "lastUpdate", descending: true, where: .arrayContains(fieldName: "participants", value: _user.email), limit: nil)
        
    }
    
    public func transform(input: Input) -> Output {
        let tableData = _chats.map { chats in
            let items = chats.map {chat in
                ChatCellViewModel(chat: chat)
            }
            return [SectionModel(header: "", items: items)]
        }.asDriver(onErrorJustReturn: [SectionModel]())
        
        let newChat = input.addNewChat
            .map { title in
            self._addNewChat(title: title)
        }.asDriver(onErrorJustReturn: ())
        
        let openChat = input.itemSelected
            .withLatestFrom(_chats) { ($0, $1) }
            .map { indexPath, chats in
                chats[indexPath.row]
            }.asDriver(onErrorJustReturn: nil)
        
        return Output(tableData: tableData,
                      newChat: newChat,
                      openChat: openChat)
    }
    
    private func _addNewChat(title: String) {
        let chat = Chat(title: title,
                        participants: [_user.email],
                        lastUpdate: Date().timeIntervalSince1970,
                        lastMessage: nil)
        self._chatUseCase.add(data: chat)
    }
}

extension ChatsViewModel.SectionModel: SectionModelType {
    typealias Item = ChatCellViewModel

    init(original: ChatsViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
