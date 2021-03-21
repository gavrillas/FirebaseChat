//
//  LogInViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class LogInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let _disposeBag = DisposeBag()
    private var _navigator: Navigator!
    private var _viewModel: LogInViewModel!
    private var _isNewUser: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = _isNewUser ?? false ? "Register" : "Log In"
        logInButton.setTitle(title, for: .normal)
        
        _bindViewModel()
    }
    
    static func create(with navigator: Navigator, viewModel: LogInViewModel, isNewUser: Bool) -> UIViewController {
        let vc = Storyboards.load(storyboard: .main, type: self)
        vc._navigator = navigator
        vc._isNewUser = isNewUser
        vc._viewModel = viewModel
        return vc
    }
    
    private func _bindViewModel() {
        let buttonTrigger = logInButton.rx.tap.asObservable()
        let email = emailTextField.rx.text.orEmpty.asObservable()
        let password = passwordTextField.rx.text.orEmpty.asObservable()
        
        let input = LogInViewModel.Input(buttonTrigger: buttonTrigger,
                             email: email,
                             password: password)
        
        let output = _viewModel.transform(input: input)
        
        output.login.drive(onNext: { [unowned self] loading in
            if loading {
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
            }
        }).disposed(by: _disposeBag)
        
        Driver.combineLatest(output.result,
                             output.user)
            .drive(onNext: { [unowned self] result, user in
                self.loadingIndicator.stopAnimating()
                switch result {
                case .success:
                    if let user = user {
                        _navigator.showChats(user: user)
                    } else {
                        self._showError(text: "Something bad happened")
                    }
                case let .error(message):
                    self._showError(text: message)
                }
            }).disposed(by: _disposeBag)
    }
    
    private func _showError(text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }
}
