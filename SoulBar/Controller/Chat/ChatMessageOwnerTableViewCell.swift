//
//  ChatMessageOwnerTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/4.
//

import UIKit

class ChatMessageOwnerTableViewCell: UITableViewCell {

    static let identifier = String(describing: ChatMessageOwnerTableViewCell.self)
    
    @IBOutlet weak var ownerImage: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
