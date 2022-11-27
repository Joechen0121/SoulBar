//
//  RecommendCollectionViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/19.
//

import UIKit

class RecommendCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: RecommendCollectionViewCell.self)
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artist: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
