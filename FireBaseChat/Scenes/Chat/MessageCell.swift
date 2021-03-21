//
//  MessageCell.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 02..
//

import UIKit
import FirebaseAuth

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageBubbleView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var verticalStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        senderImageView.layer.cornerRadius = senderImageView.frame.height / 2
        myImageView.layer.cornerRadius = myImageView.frame.height / 2
        messageBubbleView.layer.cornerRadius = messageBubbleView.frame.height / 3
    }
    
    public func config(with viewModel: MessageCellViewModel) {
        messageTextLabel.text = viewModel.message.body
        senderImageView.isHidden = !viewModel.isReceivedMsg
        myImageView.isHidden = viewModel.isReceivedMsg
        verticalStackView.alignment = viewModel.isReceivedMsg ? .leading : .trailing
    }
}

struct MessageCellViewModel {
    let message: Message
    let isReceivedMsg: Bool
    
    init(message: Message) {
        self.message = message
        isReceivedMsg = message.sender != Auth.auth().currentUser?.email
    }
}
