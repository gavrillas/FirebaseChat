//
//  ChatViewModel.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 04..
//

import Firebase
import RxSwift
import RxDataSources
import struct RxCocoa.Driver

struct ChatViewModel {
    struct SectionModel {
        let header: String
        var items: [MessageCellViewModel]
    }
    
    struct Input {
        let messageText: Observable<String?>
        let sendTrigger: Observable<Void>
        let addParticipant: Observable<Void>
    }
    
    struct Output {
        let tableData: Driver<[SectionModel]>
        let scrollTo: Driver<IndexPath>
        let sendMessage: Driver<Void>
        let addParticipant: Driver<Chat>
    }
    
    private let _messages = PublishSubject<[Message]>()
    private var _chat: Chat
    private let _messageUseCase: MessageUseCase
    private let _chatUseCase: ChatUseCase
    
    public var chatTitle: String {
        self._chat.title
    }
    
    init(chat: Chat, messageUseCase: MessageUseCase, chatUseCase: ChatUseCase) {
        _chat = chat
        _messageUseCase = messageUseCase
        _chatUseCase = chatUseCase
        
        guard let chatID = _chat.id else { return }
        _messageUseCase.listenChanges(dataSubject: _messages, orderBy: "date", descending: false, where: .isEqual(fieldName: "chat", value: chatID), limit: nil)
    }
    
    public func transform(input: Input) -> Output {
        let tableData = _messages.map { messages -> [SectionModel] in
            let items = messages.map { message in
                MessageCellViewModel(message: message)
            }
            
            return [SectionModel(header: "",
                                 items: items)]
        }.asDriver(onErrorJustReturn: [])
        
        
        let scrollTo = _messages.map { messages in
            let row = messages.count > 0 ? messages.count - 1 : 0
            return IndexPath(row: row, section: 0)
        }.asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0))
        
        
        let sendMessage = input.sendTrigger
            .withLatestFrom(input.messageText)
            .map { text in
                guard let chatID = _chat.id,
                      let body = text,
                      let sender = Auth.auth().currentUser?.email,
                      !body.isEmpty else { return }
                
                let message = Message(chatID: chatID, sender: sender, body: body, date: Date().timeIntervalSince1970)
                _messageUseCase.add(data: message)
                let chat = Chat(id: _chat.id,
                                title: _chat.title,
                                participants: _chat.participants,
                                lastUpdate: _chat.lastUpdate,
                                lastMessage: message)
                _chatUseCase.update(data: chat)
            }.asDriver(onErrorJustReturn: ())
        
        let addParticipant = input.addParticipant.map {
            _chat
        }.asDriver(onErrorJustReturn: _chat)
        
        return Output(tableData: tableData,
                      scrollTo: scrollTo,
                      sendMessage: sendMessage,
                      addParticipant: addParticipant)
    }
}

extension ChatViewModel.SectionModel: SectionModelType {
    typealias Item = MessageCellViewModel

    init(original: ChatViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

