//
//  UserCell.swift
//  FireBaseChat
//
//  Created by kristof on 2021. 03. 16..
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func config(with viewModel: UserCellViewModel) {
        userEmailLabel.text = viewModel.user.email
        let imageName = viewModel.isSelected ? "circle.fill" : "circle"
        let tintColor: UIColor = viewModel.isSelected ? .systemTeal : .systemGray5
        selectionImage.image = UIImage(systemName: imageName)
        selectionImage.tintColor = tintColor
    }

}

struct UserCellViewModel {
    let user: User
    var isSelected: Bool
    
    init(user: User, selectedUsers: [String]) {
        self.user = user
        isSelected = selectedUsers.contains(user.email)
    }
}
