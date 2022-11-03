//
//  FavoriteViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import CoreMedia

class FavoriteViewController: UIViewController {

    @IBOutlet weak var favoriteListTableView: UITableView!
    
    var favoriteSongs: [[SongsSearchInfo]] = []
    
    var favoriteAlbums: [[SongsSearchInfo]] = []
    
    var favoritePlaylist: [[SongsSearchInfo]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteListTableView.dataSource = self
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteMusicTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteAlbumsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteAlbumsTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoritePlaylistsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoritePlaylistsTableViewCell.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFavoriteSongs()
        setupFavoriteAlbums()
        setupFavoritePlaylists()
    }
    
    func setupFavoriteSongs() {
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.songs) { result in
            
            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchSong(with: id) { result in

                    self.favoriteSongs.append(result)
                    
                    DispatchQueue.main.async {

                        self.favoriteListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func setupFavoriteAlbums() {
        
        self.favoriteAlbums = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in
            
            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchAlbumsCharts(with: id) { tracks in
                    
                    self.favoriteAlbums.append(tracks)
                    
                    DispatchQueue.main.async {

                        self.favoriteListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func setupFavoritePlaylists() {
        
        self.favoritePlaylist = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.playlists) { result in
            
            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchPlaylistsCharts(with: id) { tracks in
                    
                    self.favoritePlaylist.append(tracks)
                    
                    DispatchQueue.main.async {

                        self.favoriteListTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension FavoriteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Favorite songs"
        }
        else if section == 1 {
            
            return "Favorite Albums"
        }
        else if section == 2 {
            
            return "Favorite Playlist"
        }
        else {
            
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
         
            if favoriteSongs.isEmpty {
                
                return 0
            }
            else {
                
                return 1
            }
            
        }
        else if section == 1 {

            return self.favoriteAlbums.count
        }
        else if section == 2 {
            
            return self.favoritePlaylist.count
        }
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicTableViewCell.identifier, for: indexPath) as? FavoriteMusicTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            guard !favoriteSongs.isEmpty else { return UITableViewCell() }
            
            cell.musicName.text = "Love Songs"
            
            cell.musicImage.kf.indicatorType = .activity
            
            if let artworkURL = favoriteSongs[indexPath.row][0].attributes?.artwork?.url, let width = favoriteSongs[indexPath.row][0].attributes?.artwork?.width, let height = favoriteSongs[indexPath.row][0].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.musicImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
        }
        else if indexPath.section == 1 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteAlbumsTableViewCell.identifier, for: indexPath) as? FavoriteAlbumsTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            guard !favoriteAlbums.isEmpty else { return UITableViewCell() }
            
            cell.musicName.text = favoriteAlbums[indexPath.row][0].attributes?.albumName
            cell.musicType.text = "Albums"
            
            cell.musicImage.kf.indicatorType = .activity
            
            if let artworkURL = favoriteAlbums[indexPath.row][0].attributes?.artwork?.url, let width = favoriteAlbums[indexPath.row][0].attributes?.artwork?.width, let height = favoriteAlbums[indexPath.row][0].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.musicImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
        }
        else if indexPath.section == 2 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritePlaylistsTableViewCell.identifier, for: indexPath) as? FavoritePlaylistsTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            guard !favoritePlaylist.isEmpty else { return UITableViewCell() }
            
            cell.musicName.text = favoritePlaylist[indexPath.row][0].attributes?.albumName
            cell.musicType.text = "Playlists"
            
            cell.musicImage.kf.indicatorType = .activity
            
            if let artworkURL = favoritePlaylist[indexPath.row][0].attributes?.artwork?.url, let width = favoritePlaylist[indexPath.row][0].attributes?.artwork?.width, let height = favoritePlaylist[indexPath.row][0].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.musicImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
        }
        else {
            
            return UITableViewCell()
        }
    }
}
