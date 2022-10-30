//
//  SearchAllResultTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/30.
//

import UIKit

class SearchAllResultTableViewCell: UITableViewCell {

    static let identifier = String(describing: SearchAllResultTableViewCell.self)
    
    @IBOutlet weak var allImage: UIImageView!
    
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
