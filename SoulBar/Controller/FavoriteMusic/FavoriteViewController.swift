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
    
    var favoriteLists: [[SongsSearchInfo]] = []
    
    var favoriteListsInfo: [FirebaseFavoriteListData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteListTableView.dataSource = self
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteMusicTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteAlbumsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteAlbumsTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoritePlaylistsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoritePlaylistsTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteListsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteListsTableViewCell.identifier)
        
        configureNavigationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFavoriteSongs()
        setupFavoriteAlbums()
        setupFavoritePlaylists()
        setupFavoriteLists()
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
    
    func setupFavoriteLists() {
        
        self.favoriteListsInfo = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in
            
            self.favoriteListsInfo = result

            result.forEach { result in
                
                result.songs.forEach { id in
                    
                    MusicManager.sharedInstance.fetchSong(with: id) { tracks in
                        
                        self.favoriteLists.append(tracks)
                        
                        DispatchQueue.main.async {

                            self.favoriteListTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func configureNavigationButton() {
        
        let addListButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addListButton))
                        
        self.navigationItem.rightBarButtonItem = addListButton
    
    }
    
    @objc func addListButton() {
        
        if let newListVC = self.storyboard?.instantiateViewController(withIdentifier: FavoriteAddNewListViewController.storyboardID) as? FavoriteAddNewListViewController {
            
            self.present(newListVC, animated: true)
        }
        
    }
}

extension FavoriteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            
            return false
        }
        else {
            
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            switch indexPath.section {
                
            case 1:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: favoriteAlbums[indexPath.row][0].id!)
                
                self.favoriteAlbums.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            case 2:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.playlists, id: favoritePlaylist[indexPath.row][0].id!)
                
                self.favoritePlaylist.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            case 3:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteListData(with: favoriteListsInfo[indexPath.row].name)
                
                self.favoriteListsInfo.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            default:
                
                print("Unknown state for deleting ")
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Favorite songs"
        }
        else if section == 1 {
            
            return "Favorite Albums"
        }
        else if section == 2 {
            
            return "Favorite Playlists"
        }
        else if section == 3 {
            
            return "Favorite Lists"
        }
        else {
            
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
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
        else if section == 3 {
            
            return self.favoriteListsInfo.count
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

            cell.musicName.text = favoriteAlbums[indexPath.row][0].attributes?.name
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
            
            cell.musicName.text = favoritePlaylist[indexPath.row][0].attributes?.name
            cell.musicType.text = "Playlists"
            
            cell.musicImage.kf.indicatorType = .activity
            
            if let artworkURL = favoritePlaylist[indexPath.row][0].attributes?.artwork?.url, let width = favoritePlaylist[indexPath.row][0].attributes?.artwork?.width, let height = favoritePlaylist[indexPath.row][0].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.musicImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
        }
        else if indexPath.section == 3 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteListsTableViewCell.identifier, for: indexPath) as? FavoriteListsTableViewCell else {

                fatalError("Cannot create music cell")
            }

            guard !favoriteListsInfo.isEmpty else { return UITableViewCell() }

            cell.listName.text = favoriteListsInfo[indexPath.row].name
            
            return cell
        }
        else {
            
            return UITableViewCell()
        }
    }
}
