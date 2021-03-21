//
//  RoundedButton.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue}
    }

}
