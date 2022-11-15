//
//  FavoriteListsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/7.
//

import UIKit

class FavoriteListsTableViewCell: UITableViewCell {

    static let identifier = String(describing: FavoriteListsTableViewCell.self)
    
    @IBOutlet weak var listImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var listName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listImageWidth.constant = UIScreen.main.bounds.height / 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
