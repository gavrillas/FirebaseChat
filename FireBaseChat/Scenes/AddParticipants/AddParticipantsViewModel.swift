//
//  AddParticipantsViewModel.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 16..
//

import RxSwift
import RxDataSources
import struct RxCocoa.Driver

struct AddParticipantsViewModel {
    struct SectionModel {
        let header: String
        var items: [UserCellViewModel]
    }
    
    struct Input {
        let searchText: Observable<String>
        let saveTrigger: Observable<Void>
        let select: Observable<IndexPath>
    }
    
    struct Output {
        let tableData: Driver<[SectionModel]>
        let search: Driver<Void>
        let saved: Driver<Void>
        let selected: Driver<Void>
    }
    
    private let _chat: Chat!
    private let _chatUseCase: ChatUseCase!
    private let _userUseCase: UserUseCase!
    private var _participantsEmail = BehaviorSubject<[String]>(value: [])
    private let _searchResults = BehaviorSubject<[User]>(value: [])
    
    init(chat: Chat, chatUseCase: ChatUseCase, userUseCase: UserUseCase) {
        _chat = chat
        _participantsEmail.onNext(chat.participants)
        _chatUseCase = chatUseCase
        _userUseCase = userUseCase
    }
    
    public func transform(input: Input) -> Output {
        let tableData =
            Observable.combineLatest(_searchResults,
                                     _participantsEmail)
            .map { results, selectedUsers -> [SectionModel] in
            var sections = [SectionModel]()
            
            let items = results.map { user in
                UserCellViewModel(user: user, selectedUsers: selectedUsers)
            }
            
            let resultSections = SectionModel(header: "",
                                              items: items)
            
            sections.append(resultSections)
            return sections
        }.asDriver(onErrorJustReturn: [SectionModel]())
        
        let search = input.searchText.distinctUntilChanged().map { email in
            self._userUseCase.searchUsers(email: email, result: _searchResults)
        }.asDriver(onErrorJustReturn: ())
        
        let selected =
            input.select
            .withLatestFrom(_searchResults) { indexPath, users in
                users[indexPath.row]
            }
            .withLatestFrom(_participantsEmail) { selectedUser, emails in
                guard !_chat.participants.contains(selectedUser.email) else { return }
                var participantsEmail = emails
                if participantsEmail.contains(selectedUser.email) {
                    participantsEmail.removeAll(where: { $0 == selectedUser.email})
                } else {
                    participantsEmail.append(selectedUser.email)
                }
                _participantsEmail.onNext(participantsEmail)
            }.asDriver(onErrorJustReturn: ())
        
        let saved = input.saveTrigger
        .withLatestFrom(_participantsEmail).map { emails in
            if emails != _chat.participants {
                let chat = Chat(id: _chat.id,
                                title: _chat.title,
                                participants: emails,
                                lastUpdate: Date().timeIntervalSince1970,
                                lastMessage: _chat.lastMessage)
                self._chatUseCase.update(data: chat)
            }
        }.asDriver(onErrorJustReturn: ())
        
        return Output(tableData: tableData,
                      search: search,
                      saved: saved,
                      selected: selected)
    }
}

extension AddParticipantsViewModel.SectionModel: SectionModelType {
    typealias Item = UserCellViewModel

    init(original: AddParticipantsViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
