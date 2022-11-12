//
//  FavoriteMusicDetailsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/12.
//

import UIKit

class FavoriteMusicDetailsTableViewCell: UITableViewCell {

    static let identifier = String(describing: FavoriteMusicDetailsTableViewCell.self)
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var songImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func removeFavorite(_ sender: UIButton) {
        print("1234")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songImageWidth.constant = UIScreen.main.bounds.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
