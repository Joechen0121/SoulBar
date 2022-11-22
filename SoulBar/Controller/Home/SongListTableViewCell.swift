//
//  SongListTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/29.
//

import UIKit

class SongListTableViewCell: UITableViewCell {

    static let identifier = String(describing: SongListTableViewCell.self)
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var singerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: [SongsSearchInfo], indexPath: IndexPath) {
        
        self.songImage.kf.indicatorType = .activity
        
        if let artist = data[indexPath.row].attributes?.artistName, let song = data[indexPath.row].attributes?.name, let artworkURL = data[indexPath.row].attributes?.artwork?.url, let width = data[indexPath.row].attributes?.artwork?.width, let height = data[indexPath.row].attributes?.artwork?.height {
            
            self.singerName.text = artist
            self.songName.text = song
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            self.songImage.kf.setImage(with: URL(string: pictureURL))
            
        }
    }

}
