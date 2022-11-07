//
//  NewListTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/7.
//

import UIKit

class NewListTableViewCell: UITableViewCell {

    static let identifier = String(describing: NewListTableViewCell.self)
    
    @IBOutlet weak var listStatusImage: UIImageView!
    
    @IBOutlet weak var listName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
