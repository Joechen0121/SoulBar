//
//  PlaylistsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/29.
//

import UIKit
import Kingfisher

protocol PlaylistsDelegate: AnyObject {
    
    func didSelectPlaylistsItem(playlists: PlaylistsChartsInfo, indexPath: IndexPath)
    
}

class PlaylistsTableViewCell: UITableViewCell {

    static let identifier = String(describing: PlaylistsTableViewCell.self)
    
    @IBOutlet weak var playlistsCollectionView: UICollectionView!
    
    var playlists: [PlaylistsCharts]?
    
    var playlistsNext: String?
    
    var delegate: PlaylistsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playlistsCollectionView.register(UINib.init(nibName: PlaylistsCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: PlaylistsCollectionViewCell.identifier)
        
        playlistsCollectionView.dataSource = self
        
        playlistsCollectionView.delegate = self
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: 200, height: 200)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        flowlayout.scrollDirection = .horizontal
        
        self.playlistsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
        MusicManager.sharedInstance.fetchPlaylistsCharts { result in
            
            self.playlists = result
            
            self.playlists!.forEach { playlist in

                self.playlistsNext = playlist.next

                self.loadDataWithGroup()

            }
            
            DispatchQueue.main.async {
                
                self.playlistsCollectionView.reloadData()
            }

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadDataWithGroup() {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue.global()
        
        queue.async {

            while !self.playlistsNext!.isEmpty {

                semaphore.wait()

                MusicManager.sharedInstance.fetchPlaylistsCharts(inNext: self.playlistsNext!) { result in

                    self.playlists! += result
                    
                    guard let playlistsNext = result[0].next else {

                        return
                    }
                    
                    self.playlistsNext = playlistsNext

                    semaphore.signal()
                    
                    DispatchQueue.main.async {

                        self.playlistsCollectionView.reloadData()
                    }

                }
            }
        }

    }
    
}

extension PlaylistsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playlists?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistsCollectionViewCell.identifier, for: indexPath) as? PlaylistsCollectionViewCell else {
            
            fatalError("Cannot create collection view")
        }
        
        guard let playlists = self.playlists else {
            
            return UICollectionViewCell()
            
        }
        
        cell.playlistImage.kf.indicatorType = .activity
        
        guard let playlists = playlists[0].data else {
            
            return UICollectionViewCell()
            
        }
            
        if let name = playlists[indexPath.row].attributes?.name, let artworkURL = playlists[indexPath.row].attributes?.artwork?.url, let width = playlists[indexPath.row].attributes?.artwork?.width, let height = playlists[indexPath.row].attributes?.artwork?.height {
            
            cell.playlistName.text = name
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            cell.playlistImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
}

extension PlaylistsTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let playlists = self.playlists?[0].data {
            
            delegate?.didSelectPlaylistsItem(playlists: playlists[indexPath.row], indexPath: indexPath)
        }
    }
    
}
