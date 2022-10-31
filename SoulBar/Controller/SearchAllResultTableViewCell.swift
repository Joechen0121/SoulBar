//
//  SearchAllResultTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/30.
//

import UIKit

class SearchAllResultTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: SearchAllResultTableViewCell.self)
    
    @IBOutlet weak var allImage: UIImageView!
    
    @IBOutlet weak var singerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCellArtistsData(data: [ArtistsSearchInfo], indexPath: IndexPath) {
        
        self.singerName.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.allImage.kf.setImage(with: URL(string: pictureURL))
            
        }
    }
    
    func configureCellSongsData(data: [SongsSearchInfo], indexPath: IndexPath) {
        
        self.singerName.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.allImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
    }
    
    func configureCellAlbumsData(data: [AlbumsSearchInfo], indexPath: IndexPath) {
        
        self.singerName.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.allImage.kf.setImage(with: URL(string: pictureURL))
            
        }
    }
    
}
