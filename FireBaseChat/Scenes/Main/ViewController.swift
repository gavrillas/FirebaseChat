//
//  ViewController.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import UIKit
import CLTypingLabel

class ViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: CLTypingLabel!
    private var _navigator: Navigator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = "Welcome to SuperChat💬"
        if let navigationController = navigationController {
            self._navigator = DefaultNavigator(navigationController: navigationController)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        guard let navigator = _navigator else { return }
        navigator.showLogin(isNewUser: false)
    }
    
    @IBAction func register(_ sender: Any) {
        guard let navigator = _navigator else { return }
        navigator.showLogin(isNewUser: true)
    }
}

