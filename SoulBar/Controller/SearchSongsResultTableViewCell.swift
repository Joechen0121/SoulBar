//
//  SearchSongsResultTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/30.
//

import UIKit

class SearchSongsResultTableViewCell: UITableViewCell {

    static let identifier = String(describing: SearchSongsResultTableViewCell.self)
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellData(data: [SongsSearchInfo], indexPath: IndexPath) {
        
        self.songLabel.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            self.songImage.kf.setImage(with: URL(string: pictureURL))
            
        }
    }
}
