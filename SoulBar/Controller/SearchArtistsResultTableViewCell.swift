//
//  SearchArtistsResultTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/30.
//

import UIKit

class SearchArtistsResultTableViewCell: UITableViewCell {

    static let identifier = String(describing: SearchArtistsResultTableViewCell.self)
    
    @IBOutlet weak var artistImage: UIImageView!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellData(data: [ArtistsSearchInfo], indexPath: IndexPath) {
        
        self.artistLabel.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url,
           let width = data[indexPath.row].attributes?.artwork?.width,
           let height = data[indexPath.row].attributes?.artwork?.height {
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            self.artistImage.kf.setImage(with: URL(string: pictureURL))
            
        }
    }
}
