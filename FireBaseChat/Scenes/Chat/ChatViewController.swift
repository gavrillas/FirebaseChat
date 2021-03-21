//
//  ChatViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var addParticipantButton: UIBarButtonItem!
    
    private let _disposeBag = DisposeBag()
    private var _viewModel: ChatViewModel!
    private var _navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = false
        self.title = _viewModel.chatTitle
        
        _bindViewModel()
    }
    
    static func create(with navigator: Navigator, viewModel: ChatViewModel) -> UIViewController {
        let vc = Storyboards.load(storyboard: .main, type: self)
        vc._navigator = navigator
        vc._viewModel = viewModel
        return vc
    }
    
    private func _bindViewModel(){
        let messageText = messageTextField.rx.text.asObservable()
        let sendTrigger = sendButton.rx.tap.asObservable()
        let addParticipant = addParticipantButton.rx.tap.asObservable()
        let input = ChatViewModel.Input(messageText: messageText,
                                        sendTrigger: sendTrigger,
                                        addParticipant: addParticipant)
        
        let output = _viewModel.transform(input: input)
        output.tableData
            .drive(tableView.rx.items(dataSource: _dataSource))
            .disposed(by: _disposeBag)
        
        output.scrollTo
            .drive(onNext: { [unowned self] indexPath in
                guard indexPath.row > 0 else { return }
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }).disposed(by: _disposeBag)
        
        output.sendMessage.drive(onNext: { [unowned self] in
            self.messageTextField.text = ""
        }).disposed(by: _disposeBag)
        
        output.addParticipant.drive(onNext: { [unowned self] chat in
            self._navigator.showAddParticipants(chat: chat)
        }).disposed(by: _disposeBag)
    }
}

extension ChatViewController {
    private var _dataSource: RxTableViewSectionedReloadDataSource<ChatViewModel.SectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ChatViewModel.SectionModel>(
            configureCell: { ds, tv, ip, viewModel in
                let cell = tv.dequeueReusableCell(withIdentifier: "MessageCell", for: ip) as! MessageCell
                cell.config(with: viewModel)
                return cell
            })
        return dataSource
    }
}
