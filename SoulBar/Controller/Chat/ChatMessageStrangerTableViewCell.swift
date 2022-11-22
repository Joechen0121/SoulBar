//
//  ChatMessageTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/4.
//

import UIKit

class ChatMessageStrangerTableViewCell: UITableViewCell {

    static let identifier = String(describing: ChatMessageStrangerTableViewCell.self)
    
    @IBOutlet weak var othersImage: UIImageView!
    
    @IBOutlet weak var messageBackground: UIView!
    
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
