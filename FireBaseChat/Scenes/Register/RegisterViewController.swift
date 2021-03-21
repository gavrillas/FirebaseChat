//
//  RegisterViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func register(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self] authResult, error in
                if let error = error {
                    _showError(text: error.localizedDescription)
                } else {
                    performSegue(withIdentifier: "RegisterToChats", sender: self)
                }
            }
        } else {
            _showError(text: "Email and/or password is missing")
        }
    }
    
    private func _showError(text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }
}
