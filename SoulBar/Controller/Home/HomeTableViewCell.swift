//
//  HomeTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/27.
//

import UIKit

protocol SongsDelegate: AnyObject {
    
    func didSelectSongsItem(songs: SongsChartsInfo, indexPath: IndexPath)
    
}

class SongsTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: SongsTableViewCell.self)
    
    @IBOutlet weak var songsCollectionView: UICollectionView!
    
    var newSongs = [SongsChartsInfo]()
    
    weak var delegate: SongsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCollectionView()
        
        configureFlowlayout()
        
        setupSongsCharts()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupSongsCharts() {
        
        MusicManager.sharedInstance.fetchSongsCharts { result in
            
            self.newSongs = result
            
            DispatchQueue.main.async {
                
                self.songsCollectionView.reloadData()
                
            }
        }
    }
    
    private func configureCollectionView() {
        
        self.selectionStyle = .none
        
        songsCollectionView.dataSource = self
        
        songsCollectionView.delegate = self
        
        songsCollectionView.showsVerticalScrollIndicator = false
        
        songsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func configureFlowlayout() {
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 3.5)
        
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        flowlayout.scrollDirection = .horizontal
        
        songsCollectionView.setCollectionViewLayout(flowlayout, animated: true)
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
        
        if let attribute = newSongs[indexPath.row].attributes, let artworkURL = attribute.artwork?.url, let width = attribute.artwork?.width, let height = attribute.artwork?.height {
            
            cell.songLabel.text = attribute.name
            
            cell.singerLabel.text = attribute.artistName

            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
            cell.songImage.loadImage(pictureURL)
        }
        
        return cell
    }
}

extension SongsTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
        let songs = self.newSongs[indexPath.row]
        
        delegate?.didSelectSongsItem(songs: songs, indexPath: indexPath)

    }
}
