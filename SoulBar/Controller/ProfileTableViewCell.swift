//
//  ProfileTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/6.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let identifier = String(describing: ProfileTableViewCell.self)
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageHeightConstraint.constant = UIScreen.main.bounds.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
