//
//  ChatsViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 07..
//

import UIKit
import RxSwift
import RxDataSources

class ChatsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addChatButton: UIBarButtonItem!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    
    private let _disposeBag = DisposeBag()
    private let _newChatTitle = PublishSubject<String>()
    private var _viewModel: ChatsViewModel!
    private var _navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        self.navigationItem.backButtonTitle = ""
        self.title = "Conversations"
        
        _bindViewModel()
        
        addChatButton.rx.tap.asDriver().drive(onNext: { [unowned self] in
            self.present(self._createAlert(), animated: true)
        }).disposed(by: _disposeBag)
        
        profileButton.rx.tap.asDriver().drive(onNext: { [unowned self] in
            _navigator.showProfile()
        }).disposed(by: _disposeBag)
    }
    
    static func create(with navigator: Navigator, viewModel: ChatsViewModel) -> UIViewController {
        let vc = Storyboards.load(storyboard: .main, type: self)
        vc._navigator = navigator
        vc._viewModel = viewModel
        return vc
    }
    
    private func _bindViewModel() {
        let addNewChat = _newChatTitle.asObserver()
        let itemSelected = tableView.rx.itemSelected.asObservable()
        let input = ChatsViewModel.Input(addNewChat: addNewChat,
                                         itemSelected: itemSelected)
        let output = _viewModel.transform(input: input)
        
        
        output.tableData
            .drive(tableView.rx.items(dataSource: _dataSource))
            .disposed(by: _disposeBag)
        
        output.newChat.drive()
            .disposed(by: _disposeBag)
        
        output.openChat.drive(onNext: { [unowned self] chat in
            guard let chat = chat else { return }
            _navigator.showChat(chat: chat)
        }).disposed(by: _disposeBag)
    }
    
    private func _createAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Chat's name:", message: "Give a name to your chat", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [unowned self] _ in
            guard let title = alert.textFields?.first?.text,
                  !title.isEmpty else { return }
            self._newChatTitle.onNext(title)
        }))
        return alert
    }
}

extension ChatsViewController {
    private var _dataSource: RxTableViewSectionedReloadDataSource<ChatsViewModel.SectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ChatsViewModel.SectionModel>(
            configureCell: { ds, tv, ip, chat in
                let cell = tv.dequeueReusableCell(withIdentifier: "ChatCell", for: ip) as! ChatCell
                cell.config(with: chat)
                return cell
            })
        return dataSource
    }
}
