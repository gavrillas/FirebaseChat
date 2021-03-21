//
//  Storyboards.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 06..
//

import UIKit

enum Storyboards: String {
    case main
}

extension Storyboards {
    static func get(storyboard: Storyboards) -> UIStoryboard {
        let raw = storyboard.rawValue
        let name = raw.prefix(1).uppercased() + raw.dropFirst()
        return UIStoryboard(name: name, bundle: Bundle.main)
    }
    
    static func load<Controller: UIViewController>(storyboard: Storyboards, type: Controller.Type) -> Controller{
        let sboard = Storyboards.get(storyboard: storyboard)
        return sboard.load(type: type)
    }
}

extension UIStoryboard {
    class func load<Controller: UIViewController>(from storyboard: String, type: Controller.Type, identifier: String? = nil, isInit: Bool = false) -> Controller {
        let sboard = UIStoryboard(name: storyboard, bundle: nil)
        return sboard.load(type: type, identifier: identifier, isInit: isInit)
    }

    func load<Controller: UIViewController>(type: Controller.Type, identifier: String? = nil, isInit: Bool = false) -> Controller {
        if isInit {
            guard let vc = instantiateInitialViewController() as? Controller else { fatalError() }
            return vc
        }
        let identifier = identifier ?? NSStringFromClass(Controller.self).components(separatedBy: ".").last ?? ""
        guard let vc = instantiateViewController(withIdentifier: identifier) as? Controller else { fatalError() }
        return vc
    }
}
