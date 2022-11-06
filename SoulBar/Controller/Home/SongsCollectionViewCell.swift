//
//  HomeCollectionViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit

class SongsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var songImage: UIImageView!
    
    static let identifier = String(describing: SongsCollectionViewCell.self)
    
}
