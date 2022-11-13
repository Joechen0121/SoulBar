//
//  AlbumsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit
import Kingfisher

protocol AlbumsDelegate: AnyObject {
    
    func didSelectAlbumsItem(albums: AlbumsChartsInfo, indexPath: IndexPath)
    
}

class AlbumsTableViewCell: UITableViewCell {

    static let identifier = String(describing: AlbumsTableViewCell.self)
    
    var albums: [AlbumsCharts]?
    
    var albumsNext: String?
    
    var delegate: AlbumsDelegate?
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumsCollectionView.register(UINib.init(nibName: AlbumsCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: AlbumsCollectionViewCell.identifier)
        
        albumsCollectionView.dataSource = self
        
        albumsCollectionView.delegate = self
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 4)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        flowlayout.scrollDirection = .horizontal
        
        self.albumsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
        MusicManager.sharedInstance.fetchAlbumsCharts { result in
            
            self.albums = result
            
            self.albums!.forEach { album in
                
                self.albumsNext = album.next

                self.loadDataWithGroup()

            }
            
            DispatchQueue.main.async {
                
                self.albumsCollectionView.reloadData()
            }

        }
    
    }
    
    func loadDataWithGroup() {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue.global()
        
        queue.async {

            while !self.albumsNext!.isEmpty {

                semaphore.wait()
                
                MusicManager.sharedInstance.fetchAlbumsCharts(inNext: self.albumsNext!) { result in

                    self.albums! += result
                    
                    self.albumsNext = result[0].next
                    
                    if self.albumsNext == nil {
                        
                        return
                    }
                    
                    semaphore.signal()
                    
                    DispatchQueue.main.async {
                        
                        self.albumsCollectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return albums?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumsCollectionViewCell.identifier, for: indexPath) as? AlbumsCollectionViewCell else {
            
            fatalError("Cannot create collection view")
        }
        
        guard let albums = self.albums else {
            
            return UICollectionViewCell()
            
        }
        
        cell.albumImage.kf.indicatorType = .activity
        
        if let name = albums[0].data?[indexPath.row].attributes?.name, let artworkURL = albums[0].data?[indexPath.row].attributes?.artwork?.url, let width = albums[0].data?[indexPath.row].attributes?.artwork?.width, let height = albums[0].data?[indexPath.row].attributes?.artwork?.height {
            
            cell.albumName.text = name
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            cell.albumImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
    
}

extension AlbumsTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard self.albums != nil else { return }
        
        let albums = self.albums![0].data![indexPath.row]
        
        delegate?.didSelectAlbumsItem(albums: albums, indexPath: indexPath)

    }
    
}
