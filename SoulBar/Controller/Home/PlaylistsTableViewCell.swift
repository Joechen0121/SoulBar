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
    
    var playlists = [PlaylistsChartsInfo]()
    
    var playlistsNext: String?
    
    var delegate: PlaylistsDelegate?
    
    var isLoading = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        playlistsCollectionView.register(UINib.init(nibName: PlaylistsCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: PlaylistsCollectionViewCell.identifier)
        
        playlistsCollectionView.dataSource = self
        
        playlistsCollectionView.delegate = self
        
        playlistsCollectionView.showsVerticalScrollIndicator = false
        
        playlistsCollectionView.showsHorizontalScrollIndicator = false
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 4)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        flowlayout.scrollDirection = .horizontal
        
        self.playlistsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
        MusicManager.sharedInstance.fetchPlaylistsCharts { result in
            
            guard let data = result[0].data else { return }
            
            self.playlists = data
            
            if let next = result[0].next {
                
                self.playlistsNext = next
            }
            else {
                
                self.playlistsNext = nil
                
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
    
    func loadMoreData() {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue.global()
        
        queue.async {

            if let next = self.playlistsNext {
                
                guard !self.playlists.isEmpty else { return }

                semaphore.wait()
                
                MusicManager.sharedInstance.fetchPlaylistsCharts(inNext: next) { result in

                    guard let data = result[0].data else { return }
                    
                    self.playlists += data
                    
                    self.playlistsNext = result[0].next
                    
                    semaphore.signal()
                    
                    DispatchQueue.main.async {
                        
                        self.playlistsCollectionView.reloadData()
                        
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

extension PlaylistsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == playlists.count - 1 && !self.isLoading {

            self.loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistsCollectionViewCell.identifier, for: indexPath) as? PlaylistsCollectionViewCell else {
            
            fatalError("Cannot create collection view")
        }
        
        cell.playlistImage.kf.indicatorType = .activity
            
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
        
        let playlist = self.playlists[indexPath.row]
        
        delegate?.didSelectPlaylistsItem(playlists: playlist, indexPath: indexPath)
        
    }
    
}
