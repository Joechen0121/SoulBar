//
//  HummingTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/1.
//

import UIKit

class HummingTableViewCell: UITableViewCell {

    static let identifier = String(describing: HummingTableViewCell.self)
    
    @IBOutlet weak var artists: UILabel!
    
    @IBOutlet weak var songName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
