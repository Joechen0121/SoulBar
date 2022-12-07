//
//  AlbumsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit

protocol AlbumsDelegate: AnyObject {
    
    func didSelectAlbumsItem(albums: AlbumsChartsInfo, indexPath: IndexPath)
    
}

class AlbumsTableViewCell: UITableViewCell {

    static let identifier = String(describing: AlbumsTableViewCell.self)
    
    var albums = [AlbumsChartsInfo]()
    
    var albumsNext: String?
    
    var delegate: AlbumsDelegate?
    
    var isLoading = false
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCollectionView()
        
        configureFlowlayout()
    
        setupAlbumsCharts()
    }
    
    private func configureCollectionView() {
        
        self.selectionStyle = .none
        
        albumsCollectionView.register(UINib.init(nibName: AlbumsCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: AlbumsCollectionViewCell.identifier)
        
        albumsCollectionView.dataSource = self
        
        albumsCollectionView.delegate = self
        
        albumsCollectionView.showsVerticalScrollIndicator = false
        
        albumsCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    private func setupAlbumsCharts() {
        
        MusicManager.sharedInstance.fetchAlbumsCharts { result in
            
            guard let data = result[0].data else { return }
            
            self.albums = data
            
            if let next = result[0].next {
                
                self.albumsNext = next
            }
            else {
                
                self.albumsNext = nil
                
            }
            
            DispatchQueue.main.async {
                
                self.albumsCollectionView.reloadData()
            }

        }
    }
    
    private func configureFlowlayout() {
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 4)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        flowlayout.scrollDirection = .horizontal
        
        self.albumsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
    }
    
    private func loadMoreData() {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue.global()
        
        queue.async {
            
            if let next = self.albumsNext {
                
                guard !self.albums.isEmpty else { return }

                semaphore.wait()
                
                MusicManager.sharedInstance.fetchAlbumsCharts(inNext: next) { result in

                    guard let data = result[0].data else { return }
                    
                    self.albums += data
                    
                    self.albumsNext = result[0].next
                    
                    semaphore.signal()
                    
                    DispatchQueue.main.async {
                        
                        self.albumsCollectionView.reloadData()
                        
                        self.isLoading = false
                    }
                }
            }
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension AlbumsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == albums.count - 1 && !self.isLoading {

            self.loadMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumsCollectionViewCell.identifier, for: indexPath) as? AlbumsCollectionViewCell else {
            
            fatalError("Cannot create collection view")
        }

        cell.albumImage.kf.indicatorType = .activity
        
        if let name = albums[indexPath.row].attributes?.name, let artworkURL = albums[indexPath.row].attributes?.artwork?.url, let width = albums[indexPath.row].attributes?.artwork?.width, let height = albums[indexPath.row].attributes?.artwork?.height {
            
            cell.albumName.text = name
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            cell.albumImage.loadImage(pictureURL)
            
        }
        
        return cell
    }
    
}

extension AlbumsTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let albums = self.albums[indexPath.row]
        
        delegate?.didSelectAlbumsItem(albums: albums, indexPath: indexPath)

    }
    
}
