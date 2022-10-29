//
//  SongListTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/29.
//

import UIKit

class SongListTableViewCell: UITableViewCell {

    static let identifier = String(describing: SongListTableViewCell.self)
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var singerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
