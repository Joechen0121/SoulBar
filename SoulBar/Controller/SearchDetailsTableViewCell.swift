//
//  SearchDetailsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import UIKit

class SearchDetailsTableViewCell: UITableViewCell {

    static let identifier = String(describing: SearchDetailsTableViewCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var searchImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
