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
    
    var state: Int?
    
    var favoriteListsName: String?
    
    @IBOutlet weak var playPauseView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        musicDetailsTableView.dataSource = self
        
        musicDetailsTableView.delegate = self
        
        musicDetailsTableView.register(UINib.init(nibName: FavoriteMusicDetailsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicDetailsTableViewCell.identifier)
        
        musicDetailsTableView.register(UINib.init(nibName: FavoriteMusicDetailsNoHeartTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicDetailsNoHeartTableViewCell.identifier)
        
        viewHeight.constant = UIScreen.main.bounds.height / 5
        
        playPauseButtonWidth.constant = viewHeight.constant / 3
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(playPauseButton))
        
        playPauseView.isUserInteractionEnabled = true
        
        playPauseView.addGestureRecognizer(playPauseTap)
        
        configureLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureData()
        
        self.navigationItem.largeTitleDisplayMode = .never

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureData() {
        
        guard let state = state else { return }
        
        switch state {
            
        case 0:
            
            setupFavoriteSongs()
            
            self.listTitle.text = "Love Songs"
            
        case 1:
            
            setupFavoriteAlbums()
            
            configureView()
            
        case 2:
            
            setupFavoritePlaylists()
            
            configureView()
            
        case 3:
            
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

                    self.songsTracks = result
                    
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
        
        guard let favoriteListsName = favoriteListsName else {
            return
        }
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in

            result.forEach { result in
                
                if result.name == favoriteListsName {
                    
                    result.songs.forEach { id in
                        
                        MusicManager.sharedInstance.fetchSong(with: id) { tracks in
                            
                            self.listTracks = tracks
                            
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
        
        songCount.layer.borderColor = UIColor.black.cgColor
        
        songCount.layer.borderWidth = 1
        
        songCount.layer.cornerRadius = 10
    }
    
    @objc func playPauseButton() {
        
        switch state {
            
        case 0:
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = songsTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case 1:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = albumTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case 2:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = playlistTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case 3:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = listTracks
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        default:
            
            print("Unknown state")
            
        }
    }

}

extension FavoriteMusicDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch state {
            
            
        case 0:
            
            return songsTracks.count
            
        case 1:
            
            return albumTracks.count
            
        case 2:
            
            return playlistTracks.count
            
        case 3:
            
            return listTracks.count
            
        default:
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch state {
         
        case 0:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicDetailsTableViewCell.identifier, for: indexPath) as? FavoriteMusicDetailsTableViewCell else {
                
                fatalError("Cannot create cell")
            }
            
            guard !songsTracks.isEmpty else { return UITableViewCell() }
            
            cell.songName.text = songsTracks[indexPath.row].attributes?.name
            cell.artist.text = songsTracks[indexPath.row].attributes?.artistName
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artworkURL = songsTracks[indexPath.row].attributes?.artwork?.url, let width = songsTracks[indexPath.row].attributes?.artwork?.width, let height = songsTracks[indexPath.row].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }
            
            return cell
            
        case 1:
            
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
            
        case 2:
            
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
            
        case 3:
            
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
            
        default:
            
            return UITableViewCell()
        }
    }
}

extension FavoriteMusicDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch state {
            
            
        case 0:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [songsTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
            
        case 1:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [albumTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case 2:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [playlistTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
        case 3:
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                playSongVC.songs = [listTracks[indexPath.row]]
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                
            }
            
            
        default:
            
            print("Unknown state")
        }
        

    }
}
