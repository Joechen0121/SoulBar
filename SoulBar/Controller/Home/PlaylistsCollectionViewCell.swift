//
//  PlaylistsCollectionViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/29.
//

import UIKit

class PlaylistsCollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: PlaylistsCollectionViewCell.self)
    
    @IBOutlet weak var playlistImage: UIImageView!
    
    @IBOutlet weak var playlistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
