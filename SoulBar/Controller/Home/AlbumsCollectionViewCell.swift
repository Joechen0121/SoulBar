//
//  AlbumsCollectionViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit

class AlbumsCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: AlbumsCollectionViewCell.self)
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var albumName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
