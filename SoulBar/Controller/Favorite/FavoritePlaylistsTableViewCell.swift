//
//  FavoritePlaylistsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/3.
//

import UIKit

class FavoritePlaylistsTableViewCell: UITableViewCell {

    static let identifier = String(describing: FavoritePlaylistsTableViewCell.self)
    
    @IBOutlet weak var musicImageHeight: NSLayoutConstraint!

    @IBOutlet weak var musicImage: UIImageView!

    @IBOutlet weak var musicName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        musicImageHeight.constant = UIScreen.main.bounds.height / 7
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
