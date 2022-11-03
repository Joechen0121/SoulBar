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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
