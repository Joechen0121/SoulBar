//
//  SearchAlbumsResultTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/30.
//

import UIKit

class SearchAlbumsResultTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: SearchAlbumsResultTableViewCell.self)
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var albumName: UILabel!
    
    @IBOutlet weak var singerName: UILabel!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        widthConstraint.constant = UIScreen.main.bounds.height / 7
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellData(data: [AlbumsSearchInfo], indexPath: IndexPath) {

        guard !data.isEmpty else { return }
        
        guard data.count > indexPath.row else { return }

        self.albumName.text = data[indexPath.row].attributes?.name
        self.singerName.text = data[indexPath.row].attributes?.artistName
        if let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            self.albumImage.kf.setImage(with: URL(string: pictureURL))
            
        }
    }
}
