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
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        widthConstraint.constant = UIScreen.main.bounds.height / 7
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        allImage.image = nil
        
        singerName.text = ""
        
    }
    
    func configureCellArtistsData(data: [ArtistsSearchInfo], indexPath: IndexPath) {

        guard !data.isEmpty else { return }
        
        guard data.count > indexPath.row else { return }

        self.singerName.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.allImage.loadImage(pictureURL)
            
        }
    }
    
    func configureCellSongsData(data: [SongsSearchInfo], indexPath: IndexPath) {
        
        guard !data.isEmpty else { return }
        
        self.singerName.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.allImage.loadImage(pictureURL)
            
        }
        
    }
    
    func configureCellAlbumsData(data: [AlbumsSearchInfo], indexPath: IndexPath) {
        
        guard !data.isEmpty else { return }
        
        self.singerName.text = data[indexPath.row].attributes?.name
        
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.allImage.loadImage(pictureURL)
            
        }
    }
    
}
