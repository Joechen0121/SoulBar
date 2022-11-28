//
//  FavroiteMusicDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/12.
//

import UIKit
import Kingfisher

class FavoriteMusicDetailsViewController: UIViewController {
    
    static let storyboardID = "FavoriteMusicDetailsVC"

    @IBOutlet weak var playPauseButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var musicDetailsTableView: UITableView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var playPuaseButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var songCount: UILabel!
    
    @IBOutlet weak var listTitle: UILabel!
    
    @IBOutlet weak var imageLogo: UIImageView!
    
    var favoriteSongsInfo: [SongsSearchInfo]?
    
    var favoriteListsInfo: FirebaseFavoriteListData?
    
    var songsTracks: [SongsSearchInfo] = []
    
    var albumTracks: [SongsSearchInfo] = []
    
    var playlistTracks: [SongsSearchInfo] = []
    
    var listTracks: [SongsSearchInfo] = []
    
    var hasHeart = false
    
    var shouldChangeImage = false
    
    var imageState: Int? = 0
    
    var listName: String = ""
    
    var state: FavoriteType?
    
    var favoriteListsName: String?
    
    @IBOutlet weak var playPauseView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        musicDetailsTableView.dataSource = self
        
        musicDetailsTableView.delegate = self
        
        musicDetailsTableView.showsVerticalScrollIndicator = false
        
        musicDetailsTableView.showsHorizontalScrollIndicator = false
        
        musicDetailsTableView.register(UINib.init(nibName: FavoriteMusicDetailsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicDetailsTableViewCell.identifier)
        
        musicDetailsTableView.register(UINib.init(nibName: FavoriteMusicDetailsNoHeartTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicDetailsNoHeartTableViewCell.identifier)

        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(playPauseButton))
        
        playPauseView.isUserInteractionEnabled = true
        
        playPauseView.addGestureRecognizer(playPauseTap)
        
        playPuaseButtonWidth.constant = imageLogo.frame.height / 5
        
        viewHeight.constant = UIScreen.main.bounds.height / 5
        
        configureLabel()
        
        self.songCount.text = " \(self.songsTracks.count) songs "
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureData()
        
        self.navigationItem.largeTitleDisplayMode = .never

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        songsTracks = []
        
        albumTracks = []
        
        playlistTracks = []
        
        listTracks = []
        
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureData() {
        
        guard let state = state else { return }
        
        switch state {
            
        case .FavSongs:
            
            setupFavoriteSongs()
            
            self.listTitle.text = "Liked Songs"
            
        case .FavAlbums:
            
            setupFavoriteAlbums()
            
            configureView()
            
        case .FavPlaylists:
            
            setupFavoritePlaylists()
            
            configureView()
            
        case .FavLists:
            
            setupFavoriteLists()
            
            self.listTitle.text = favoriteListsName ?? ""
            
        default:
            
            print("Unknown state")
            
        }
    }
    
    func configureView() {
        
        guard let favoriteSongsInfo = favoriteSongsInfo else {
            return
        }
        
        if let artworkURL = favoriteSongsInfo[0].attributes?.artwork?.url, let width = favoriteSongsInfo[0].attributes?.artwork?.width, let height = favoriteSongsInfo[0].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            self.imageLogo.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        self.listTitle.text = favoriteSongsInfo[0].attributes?.name
    }
    
    func setupFavoriteSongs() {
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.songs) { result in
            
            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchSong(with: id) { result in

                    self.songsTracks.append(result[0])
                    
                    DispatchQueue.main.async {
                        
                        self.songCount.text = " \(self.songsTracks.count) songs "

                        self.musicDetailsTableView.reloadData()
                    }
            
                }
            }
        }
    }
    
    func setupFavoriteAlbums() {
        
        guard let albumID = favoriteSongsInfo?[0].id else { return }
        
        MusicManager.sharedInstance.fetchAlbumsTracks(with: albumID) { tracks in
            
            self.albumTracks = tracks
            
            DispatchQueue.main.async {
                
                self.songCount.text = " \(self.albumTracks.count) songs "
                
                self.musicDetailsTableView.reloadData()
            }
            
        }
    }
    
    func setupFavoritePlaylists() {
        
        
        guard let favoriteSongsInfo = favoriteSongsInfo else {
            
            return
        }
     
        favoriteSongsInfo.forEach { song in
                
            MusicManager.sharedInstance.fetchPlaylistsTracks(with: song.id!) { tracks in
                
                self.playlistTracks = tracks

                DispatchQueue.main.async {
                    
                    self.songCount.text = " \(self.playlistTracks.count) songs "

                    self.musicDetailsTableView.reloadData()
                }
            }
        }
    }
    
    func setupFavoriteLists() {
        
        if KeychainManager.sharedInstance.id == nil {
            let authVC = storyboard!.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as! AppleAuthViewController
            authVC.modalPresentationStyle = .overCurrentContext
            self.present(authVC, animated: false)
            
            return
        }
        
        guard let favoriteListsName = favoriteListsName else {
            return
        }
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in

            result.forEach { result in
                
                if result.name == favoriteListsName {
                    
                    result.songs.forEach { id in
                        
                        MusicManager.sharedInstance.fetchSong(with: id) { tracks in
                            
                            self.listTracks.append(tracks[0])
                            
                            DispatchQueue.main.async {
                                
                                self.songCount.text = " \(self.listTracks.count) songs "

                                self.musicDetailsTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func configureLabel() {
        
        songCount.layer.masksToBounds = true
        
        songCount.layer.borderColor = UIColor.gray.cgColor
        
        songCount.layer.borderWidth = 1
        
        songCount.layer.cornerRadius = 10
    }
    
    @objc func playPauseButton() {
        
        guard let state = state else { return }

        switch state {
            
        case .FavSongs:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = songsTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case .FavAlbums:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = albumTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case .FavPlaylists:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = playlistTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case .FavLists:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = listTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
        }
    }

}

extension FavoriteMusicDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let state = state else { return 0 }
        
        switch state {
            
        case .FavSongs:
            
            return songsTracks.count
            
        case .FavAlbums:
            
            return albumTracks.count
            
        case .FavPlaylists:
            
            return playlistTracks.count
            
        case .FavLists:
            
            return listTracks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let state = state else { return UITableViewCell() }
        
        switch state {
         
        case .FavSongs:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicDetailsTableViewCell.identifier, for: indexPath) as? FavoriteMusicDetailsTableViewCell else {
                
                fatalError("Cannot create cell")
            }
            
            guard !songsTracks.isEmpty else { return UITableViewCell() }
            
            cell.songName.text = songsTracks[indexPath.row].attributes?.name
            cell.artist.text = songsTracks[indexPath.row].attributes?.artistName
            
            cell.delegate = self
            cell.indexPath = indexPath
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artworkURL = songsTracks[indexPath.row].attributes?.artwork?.url, let width = songsTracks[indexPath.row].attributes?.artwork?.width, let height = songsTracks[indexPath.row].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }
            
            return cell
            
        case .FavAlbums:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicDetailsNoHeartTableViewCell.identifier, for: indexPath) as? FavoriteMusicDetailsNoHeartTableViewCell else {
                
                fatalError("Cannot create cell")
            }
            
            guard !albumTracks.isEmpty else { return UITableViewCell() }
            
            cell.songName.text = albumTracks[indexPath.row].attributes?.name
            cell.artist.text = albumTracks[indexPath.row].attributes?.artistName
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artworkURL = albumTracks[indexPath.row].attributes?.artwork?.url, let width = albumTracks[indexPath.row].attributes?.artwork?.width, let height = albumTracks[indexPath.row].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }
            
            return cell
            
        case .FavPlaylists:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicDetailsNoHeartTableViewCell.identifier, for: indexPath) as? FavoriteMusicDetailsNoHeartTableViewCell else {
                
                fatalError("Cannot create cell")
            }
            
            guard !playlistTracks.isEmpty else { return UITableViewCell() }
            
            cell.songName.text = playlistTracks[indexPath.row].attributes?.name
            cell.artist.text = playlistTracks[indexPath.row].attributes?.artistName
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artworkURL = playlistTracks[indexPath.row].attributes?.artwork?.url, let width = playlistTracks[indexPath.row].attributes?.artwork?.width, let height = playlistTracks[indexPath.row].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }
            
            return cell
            
        case .FavLists:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicDetailsNoHeartTableViewCell.identifier, for: indexPath) as? FavoriteMusicDetailsNoHeartTableViewCell else {
                
                fatalError("Cannot create cell")
            }
            
            guard !listTracks.isEmpty else { return UITableViewCell() }
            
            cell.songName.text = listTracks[indexPath.row].attributes?.name
            cell.artist.text = listTracks[indexPath.row].attributes?.artistName
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artworkURL = listTracks[indexPath.row].attributes?.artwork?.url, let width = listTracks[indexPath.row].attributes?.artwork?.width, let height = listTracks[indexPath.row].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }
            
            return cell
        }
    }
}

extension FavoriteMusicDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let state = state else { return }
        
        switch state {
            
        case .FavSongs:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [songsTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case .FavAlbums:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [albumTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case .FavPlaylists:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [playlistTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case .FavLists:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [listTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
        }
    }
}

extension FavoriteMusicDetailsViewController: FavoriteMusicDetailsTableViewDelegate {
    
    func removeTableViewCell(at indexPath: IndexPath) {
        
        guard let songID = songsTracks[indexPath.row].id else { return }
        
        FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.songs, id: songID)
        
        self.songsTracks.remove(at: indexPath.row)
        
        musicDetailsTableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
    
        DispatchQueue.main.async {
            
            self.songCount.text = " \(self.songsTracks.count) songs "
            
            self.musicDetailsTableView.reloadData()
        }
    }
}
