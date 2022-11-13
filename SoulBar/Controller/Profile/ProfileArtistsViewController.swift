//
//  ProfileArtistsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/13.
//

import UIKit
import Kingfisher

class ProfileArtistsViewController: UIViewController {

    static let storyboardID = "ProfileArtistsVC"
    
    var artistsID: FirebaseFavoriteData?
    
    var artistsInfo: [ArtistsSearchInfo] = []
    
    @IBOutlet weak var artistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        artistTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.title = "Liked Artists"
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.artists) { result in

            self.artistsID = result
            
            guard let artistsID = self.artistsID else { return }
            
            artistsID.id.forEach { id in
                
                MusicManager.sharedInstance.fetchArtist(with: id) { artist in
                    
                    self.artistsInfo.append(artist[0])
                    
                    DispatchQueue.main.async {
                        
                        self.artistTableView.reloadData()
                    }
                }
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        artistsInfo = []
        
        self.navigationItem.largeTitleDisplayMode = .always
    }

}
extension ProfileArtistsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return artistsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileArtistsTableViewCell.identifier, for: indexPath) as? ProfileArtistsTableViewCell else {
            fatalError("Cannot create artist cell")
        }
        
        guard !artistsInfo.isEmpty else { return UITableViewCell() }
        
        cell.artistName.text = self.artistsInfo[indexPath.row].attributes?.name
        
        cell.artistImage.kf.indicatorType = .activity
        
        if let artworkURL = artistsInfo[indexPath.row].attributes?.artwork?.url, let width = artistsInfo[indexPath.row].attributes?.artwork?.width, let height = artistsInfo[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            cell.artistImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
}
