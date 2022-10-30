//
//  SearchArtistsResultTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/30.
//

import UIKit

class SearchArtistsResultTableViewCell: UITableViewCell {

    static let identifier = String(describing: SearchArtistsResultTableViewCell.self)
    
    @IBOutlet weak var artistImage: UIImageView!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
