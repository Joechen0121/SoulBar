//
//  AlbumsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit
import Kingfisher

class AlbumsTableViewCell: UITableViewCell {

    static let identifier = String(describing: AlbumsTableViewCell.self)
    
    let musicManager = MusicManager()
    
    var albums: [AlbumsCharts]?
    
    var albumsNext: String?
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumsCollectionView.register(UINib.init(nibName: AlbumsCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: AlbumsCollectionViewCell.identifier)
        
        albumsCollectionView.dataSource = self
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: 200, height: 200)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        flowlayout.scrollDirection = .horizontal
        
        self.albumsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
        
        musicManager.fetchAlbumsCharts { result in
            
            self.albums = result
            
            self.albums!.forEach { album in
                
                self.albumsNext = album.next

                self.loadDataWithGroup()

            }
            
            DispatchQueue.main.async {
                
                self.albumsCollectionView.reloadData()
            }

        }
        
//            for albumIndex in 0..<albums.count {
//
//                if let datas = albums[albumIndex].data {
//
//                    for dataIndex in 0..<datas.count {
//
//                        self.musicManager.fetchAlbumsCharts(with: datas[dataIndex].id) { result in
//
//                            print(result)
//                        }
//                    }
//                }
//
//            }
    
    }
    
    func loadDataWithGroup() {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue.global()
        
        queue.async {

            while !self.albumsNext!.isEmpty {
    
                semaphore.wait()
                
                self.musicManager.fetchAlbumsCharts(inNext: self.albumsNext!) { result in
                    
                    self.albums! += result
                    
                    self.albumsNext = result[0].next

                    semaphore.signal()
                }
                
                DispatchQueue.main.async {
                    
                    self.albumsCollectionView.reloadData()
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
        
        if let name = albums[0].data![indexPath.row].attributes?.name,
           let artworkURL = albums[0].data![indexPath.row].attributes?.artwork?.url,
           let width = albums[0].data![indexPath.row].attributes?.artwork?.width,
           let height = albums[0].data![indexPath.row].attributes?.artwork?.height
            
        {
            cell.albumName.text = name
            
            let pictureURL = musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
    
            cell.albumImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
    
    
    
    
}
