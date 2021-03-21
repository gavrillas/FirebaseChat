//
//  ProfileViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 10..
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var saveButton: RoundedButton!
    @IBOutlet weak var cancelButton: RoundedButton!
    @IBOutlet weak var actionStackViews: UIStackView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
        // Do any additional setup after loading the view.
        
        _bindViewModel()
    }
    
    private let _disposeBag = DisposeBag()
    private var _viewModel: ProfileViewModel!
    private var _naviagor: Navigator!
    
    static func create(with navigator: Navigator, viewModel: ProfileViewModel) -> UIViewController {
        let vc = Storyboards.load(storyboard: .main, type: self)
        vc._viewModel = viewModel
        vc._naviagor = navigator
        return vc
    }
    
    private func _bindViewModel() {
        let logOut = logOutButton.rx.tap.asObservable()
        let edit = editProfileButton.rx.tap.map{ true }.asObservable()
        let nickname = nicknameTextField.rx.text.asObservable()
        let age = ageTextField.rx.text.map { text in Int(text ?? "nil") }.asObservable()
        let saveChanges = saveButton.rx.tap.map{ false }.asObservable()
        let cancelChanges = cancelButton.rx.tap.map{ false }.asObservable()
        
        let input = ProfileViewModel.Input(logOut: logOut,
                                           edit: edit,
                                           nickname: nickname,
                                           age: age,
                                           saveChanges: saveChanges,
                                           cancelChanges: cancelChanges)
        let output = _viewModel.transform(input: input)
        
        output.user.drive(onNext: { [unowned self] user in
            guard let user = user else { return }
            self.nicknameTextField.text = user.nickname
            self.ageTextField.text = user.age != nil ? "\(user.age!)" : "Unknown"
            self.emailLabel.text = user.email
        }).disposed(by: _disposeBag)
        
        output.editing.drive(onNext: { [unowned self] isEditing in
            actionStackViews.isHidden = !isEditing
            editProfileButton.isHidden = isEditing
            nicknameTextField.isUserInteractionEnabled = isEditing
            ageTextField.isUserInteractionEnabled = isEditing
            nicknameTextField.borderStyle = isEditing ? .roundedRect : .none
            ageTextField.borderStyle = isEditing ? .roundedRect : .none
        }).disposed(by: _disposeBag)
        
        output.logOut.drive(onNext: { [unowned self] in
            self.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: _disposeBag)
        
        
        output.saved.drive(onNext: { [unowned self] success in
            let title = success ? "Saved successfuly" : "Something went wrong"
            self._showAlert(title: title)
        }).disposed(by: _disposeBag)
    }
    
    private func _showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        UIView.animate(withDuration: 2, animations: { () -> Void in
            alert.dismiss(animated: true)
        })
    }
}
