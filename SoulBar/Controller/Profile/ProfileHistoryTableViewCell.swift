//
//  ProfileHistoryTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/13.
//

import UIKit

class ProfileHistoryTableViewCell: UITableViewCell {

    static let identifier = String(describing: ProfileHistoryTableViewCell.self)
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
