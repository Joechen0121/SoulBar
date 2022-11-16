//
//  ProfileEventCollectionViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/16.
//

import UIKit
import Cards

class ProfileEventCollectionViewCell: UICollectionViewCell {
 
    static let identifier = String(describing: ProfileEventCollectionViewCell.self)
    
    @IBOutlet weak var eventCard: CardHighlight!
    
}
