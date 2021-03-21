//
//  Navigator.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 06..
//

import UIKit

protocol Navigator {
    func showLogin(isNewUser: Bool)
    func showChats(user:User)
    func showChat(chat: Chat)
    func showProfile()
    func showAddParticipants(chat: Chat)
}

final class DefaultNavigator: Navigator {
    private weak var _navigationController: UINavigationController!
    
    private let _chatUseCase = ChatRepository()
    private let _userUseCase = UserRepository()
    private let _messageUseCase = MessageRepository()

    init(navigationController: UINavigationController) {
        _navigationController = navigationController
    }
    
    func showLogin(isNewUser: Bool) {
        let viewModel = LogInViewModel(isNewUser: isNewUser, userUseCase: _userUseCase)
        let viewController = LogInViewController.create(with: self, viewModel: viewModel, isNewUser: isNewUser)
        _navigationController.pushViewController(viewController, animated: true)
    }
    
    func showChats(user: User) {
        let viewModel = ChatsViewModel(user: user, chatUseCase: _chatUseCase, messageUseCase: _messageUseCase)
        let viewController = ChatsViewController.create(with: self, viewModel: viewModel)
        _navigationController.pushViewController(viewController, animated: true)
    }
    
    func showChat(chat: Chat) {
        let viewModel = ChatViewModel(chat: chat,
                                      messageUseCase: MessageRepository(),
                                      chatUseCase: ChatRepository())
        let viewController = ChatViewController.create(with: self, viewModel: viewModel)
        _navigationController.pushViewController(viewController, animated: true)
    }
    
    func showProfile() {
        let viewModel = ProfileViewModel(userUseCase: _userUseCase)
        let viewController = ProfileViewController.create(with: self, viewModel: viewModel)
        _navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAddParticipants(chat: Chat) {
        let viewModel = AddParticipantsViewModel(chat: chat, chatUseCase: _chatUseCase, userUseCase: _userUseCase)
        let viewController = AddParticipantsViewController.create(with: viewModel)
        _navigationController.present(viewController, animated: true)
    }
}
