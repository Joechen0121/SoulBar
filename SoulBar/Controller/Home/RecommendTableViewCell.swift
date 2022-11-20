//
//  RecommendTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/20.
//

import UIKit

protocol RecommendDelegate: AnyObject {
    
    func didSelectRecommendItem(songs: SongsChartsInfo, indexPath: IndexPath)
    
}

class RecommendTableViewCell: UITableViewCell {

    static let identifier = String(describing: RecommendTableViewCell.self)
    
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    
    var songs = [SongsChartsInfo]()
    
    var songsNext: String?
    
    weak var delegate: RecommendDelegate?
    
    var isLoading = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recommendCollectionView.dataSource = self
        
        recommendCollectionView.delegate = self
        
        recommendCollectionView.register(UINib.init(nibName: RecommendCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: RecommendCollectionViewCell.identifier)
        
        configureCellSize()
        
        MusicManager.sharedInstance.fetchSongsChartsNext(completion: { result in

            self.songsNext = result[0].next
            
            if let next = self.songsNext {
                
                MusicManager.sharedInstance.fetchSongsCharts(inNext: next) { result in

                    guard let data = result[0].data else { return }
                    
                    self.songs = data
                    
                    self.songsNext = result[0].next
                    
                    DispatchQueue.main.async {
                        
                        self.recommendCollectionView.reloadData()
                    }
                }
            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellSize() {
        
        let itemSpace: Double = 3
        
        let columnCount: Double = 2
        
        let flowlayout = UICollectionViewFlowLayout()
        
        let width = floor((UIScreen.main.bounds.width - itemSpace * (columnCount - 1)) / columnCount)
        
        flowlayout.itemSize = CGSize(width: width, height: width + 50)
    
        flowlayout.estimatedItemSize = .zero
        
        flowlayout.minimumInteritemSpacing = itemSpace
        
        flowlayout.minimumLineSpacing = itemSpace
        
        self.recommendCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
    }
    
    func loadMoreData() {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue.global()
        
        queue.async {

            if let next = self.songsNext {
                
                guard !self.songs.isEmpty else { return }

                semaphore.wait()
                
                MusicManager.sharedInstance.fetchSongsCharts(inNext: next) { result in

                    guard let data = result[0].data else { return }
                    
                    self.songs += data
                    
                    self.songsNext = result[0].next
                    
                    semaphore.signal()
                    
                    DispatchQueue.main.async {
                        
                        self.recommendCollectionView.reloadData()
                        
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
}

extension RecommendTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == songs.count - 1 && !self.isLoading {

            self.loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: RecommendCollectionViewCell.identifier, for: indexPath) as? RecommendCollectionViewCell else {
            
            fatalError("Cannot create event cells")
        }
        
        cell.songImage.kf.indicatorType = .activity
            
        if let name = songs[indexPath.row].attributes?.name, let artworkURL = songs[indexPath.row].attributes?.artwork?.url, let width = songs[indexPath.row].attributes?.artwork?.width, let height = songs[indexPath.row].attributes?.artwork?.height {
            
            cell.songName.text = name
            
            cell.artist.text = songs[indexPath.row].attributes?.artistName
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            cell.songImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
}

extension RecommendTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let song = self.songs[indexPath.row]
        
        delegate?.didSelectRecommendItem(songs: song, indexPath: indexPath)
        
    }
    
}
