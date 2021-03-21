//
//  ChatCell.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 07..
//

import UIKit
import RxSwift

class ChatCell: UITableViewCell {
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var chatImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func config(with viewModel: ChatCellViewModel) {
        chatTitle.text = viewModel.chat.title
        lastMessage.text = viewModel.chat.lastMessage?.body ?? ""
    }
}

struct ChatCellViewModel {
    let chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
    }
}
