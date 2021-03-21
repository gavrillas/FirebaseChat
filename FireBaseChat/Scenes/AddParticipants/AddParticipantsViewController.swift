//
//  AddParticipantsViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 15..
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class AddParticipantsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    private let _disposeBag = DisposeBag()
    private var _viewModel: AddParticipantsViewModel!
    
    static func create(with viewModel: AddParticipantsViewModel) -> UIViewController {
        let vc = Storyboards.load(storyboard: .main, type: self)
        vc._viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _bindViewModel()

        // Do any additional setup after loading the view.
    }
    
    private func _bindViewModel() {
        let searchText = searchTextField.rx.text.orEmpty.asObservable()
        let saveTrigger = saveButton.rx.tap.asObservable()
        let select = tableView.rx.itemSelected.asObservable()
        let input = AddParticipantsViewModel.Input(searchText: searchText,
                                                   saveTrigger: saveTrigger,
                                                   select: select)
        let output = _viewModel.transform(input: input)
        
        output.tableData
            .drive(tableView.rx.items(dataSource: _dataSource))
            .disposed(by: _disposeBag)
        
        output.search
            .drive()
            .disposed(by: _disposeBag)
        
        output.selected
            .drive()
            .disposed(by: _disposeBag)
        
        Driver.merge(output.saved,
                     cancelButton.rx.tap.asDriver())
            .drive(onNext: { [unowned self] in
                self.dismiss(animated: true)
            }).disposed(by: _disposeBag)
    }
}

extension AddParticipantsViewController {
    private var _dataSource: RxTableViewSectionedReloadDataSource<AddParticipantsViewModel.SectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<AddParticipantsViewModel.SectionModel>(
            configureCell: { ds, tv, ip, viewModel in
                let cell = tv.dequeueReusableCell(withIdentifier: "UserCell", for: ip) as! UserCell
                cell.config(with: viewModel)
                return cell
            })
        return dataSource
    }
}
