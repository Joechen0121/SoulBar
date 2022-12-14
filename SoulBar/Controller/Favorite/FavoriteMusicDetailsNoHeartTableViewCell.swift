//
//  FavoriteMusicDetailsNoHeartTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/12.
//

import UIKit

class FavoriteMusicDetailsNoHeartTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: FavoriteMusicDetailsNoHeartTableViewCell.self)

    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var songImageWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songImageWidth.constant = UIScreen.main.bounds.height / 10
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
