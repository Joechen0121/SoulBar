//
//  ProfileArtistsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/13.
//

import UIKit

class ProfileArtistsViewController: UIViewController {

    static let storyboardID = "ProfileArtistsVC"
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var artistsID: FirebaseFavoriteData?
    
    var artistsInfo: [ArtistsSearchInfo] = []
    
    @IBOutlet weak var artistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
        
        configureActivityView()
        
        loadDataWithGroup()

    }
    
    private func configureNavigationBar() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.title = "Liked Artists"
        
    }
    
    private func configureActivityView() {
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        activityIndicatorView.isHidden = false
    }
    
    private func configureTableView() {
        
        artistTableView.dataSource = self
        
        artistTableView.delegate = self
        
        artistTableView.showsVerticalScrollIndicator = false
        
        artistTableView.showsHorizontalScrollIndicator = false
        
    }
    
    func configureNoResult() {
        
        let label = UILabel(frame: CGRect(x: 0, y: self.view.center.y, width: 290, height: 70))
        
        label.center = self.view.center
        
        label.textAlignment = .center
        
        label.textColor = .darkGray
        
        label.font = UIFont.systemFont(ofSize: 17)
        
        label.text = "No Favorite Artists"

        self.view.addSubview(label)
    }
    
    private func loadDataWithGroup() {
        
        let group = DispatchGroup()
        
        let queue = DispatchQueue.global()

        queue.async(group: group) {
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.artists) { result in

                guard !result.id.isEmpty && result.id[0] != "" else {
                    
                    self.configureNoResult()
                    
                    DispatchQueue.main.async {
                        
                        self.artistTableView.reloadData()
                        
                        self.activityIndicatorView.stopAnimating()
                        
                        self.activityIndicatorView.isHidden = true
                    }
                    
                    return
                    
                }
                
                self.artistsID = result

                guard let artistsID = self.artistsID else { return }
            
                artistsID.id.forEach { id in
    
                    group.enter()
                    
                    MusicManager.sharedInstance.fetchArtist(with: id) { artist in
                        
                        self.artistsInfo.append(artist[0])
                     
                        group.leave()
                    }
                    
                }
                
                group.notify(queue: .main) {
                    
                    DispatchQueue.main.async {
                        
                        self.artistTableView.reloadData()
                        
                        self.activityIndicatorView.stopAnimating()
                        
                        self.activityIndicatorView.isHidden = true
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
        
        cell.delegate = self

        cell.indexPath = indexPath
        
        cell.artistImage.kf.indicatorType = .activity
        
        if let artworkURL = artistsInfo[indexPath.row].attributes?.artwork?.url, let width = artistsInfo[indexPath.row].attributes?.artwork?.width, let height = artistsInfo[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            cell.artistImage.loadImage(pictureURL)
            
        }
        
        return cell
    }
}

extension ProfileArtistsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {

            songlistVC.state = 3

            songlistVC.artistID = artistsInfo[indexPath.row].id
            
            songlistVC.artistInfo = artistsInfo[indexPath.row]
            
            songlistVC.artistURL = artistsInfo[indexPath.row].attributes?.url
            
            self.navigationController?.pushViewController(songlistVC, animated: true)
        }
    }
    
}

extension ProfileArtistsViewController: ProfileArtistsTableViewDelegate {
    
    func removeTableViewCell(at indexPath: IndexPath) {
        
        guard let artistID = artistsInfo[indexPath.row].id else { return }
        
        FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.artists, id: artistID)
        
        self.artistsInfo.remove(at: indexPath.row)
        
        artistTableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
        
        DispatchQueue.main.async {
            
            self.artistTableView.reloadData()
        }
    }
}
