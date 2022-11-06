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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
