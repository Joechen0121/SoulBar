//
//  FavoriteMusicTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/3.
//

import UIKit

class FavoriteMusicTableViewCell: UITableViewCell {

    static let identifier = String(describing: FavoriteMusicTableViewCell.self)
    
    @IBOutlet weak var musicImage: UIImageView!
    
    @IBOutlet weak var musicName: UILabel!
    
    @IBOutlet weak var musicImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        musicImageHeight.constant = UIScreen.main.bounds.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
