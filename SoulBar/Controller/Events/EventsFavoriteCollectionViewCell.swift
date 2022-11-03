//
//  EventsFavoriteCollectionViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/3.
//

import UIKit
import Cards

class EventsFavoriteCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: EventsFavoriteCollectionViewCell.self)
        
    @IBOutlet weak var favoriteCards: CardHighlight!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
