//
//  EventsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    static let identifier = String(describing: EventsTableViewCell.self)
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var eventPlace: UILabel!
    
    @IBOutlet weak var eventDate: UILabel!
    
    @IBOutlet weak var eventImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
