//
//  HomeTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit
import Kingfisher

class SongsTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: SongsTableViewCell.self)
 
    @IBOutlet weak var songsCollectionView: UICollectionView!
    
    var newSongs = [SongsChartsInfo]()
    
    let musicManager = MusicManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songsCollectionView.dataSource = self
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: 200, height: 200)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        flowlayout.scrollDirection = .horizontal
        
        self.songsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
        musicManager.fetchSongsCharts { result in
            
            self.newSongs = result
            
            DispatchQueue.main.async {
                
                self.songsCollectionView.reloadData()
                
            }
            
        }
    }

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
}



}

extension SongsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return newSongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongsCollectionViewCell.identifier, for: indexPath) as? SongsCollectionViewCell else {
            
            fatalError("Cannot create collection view")
        }
        
        if let song = newSongs[indexPath.row].attributes?.name,
           let singer = newSongs[indexPath.row].attributes?.artistName {
            
            cell.songLabel.text = song
            cell.singerLabel.text = singer
        }
        
        cell.songImage.kf.indicatorType = .activity
        
        if let artworkURL = newSongs[indexPath.row].attributes?.artwork?.url,
           let width = newSongs[indexPath.row].attributes?.artwork?.width,
           let height = newSongs[indexPath.row].attributes?.artwork?.height
        {
            
            let pictureURL = musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            cell.songImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
}
