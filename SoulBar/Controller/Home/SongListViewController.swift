//
//  SongListViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/29.
//

import UIKit
import Kingfisher

class SongListViewController: UIViewController {
    
    static let storyboardID = "SongListVC"
    
    @IBOutlet weak var songListImage: UIImageView!
    
    @IBOutlet weak var songListTableView: UITableView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    enum SongListType: Int {
        
        case fromPlaylist = 0
        
        case fromAlbums
        
        case fromAlbumsSearch
        
        case fromArtist
        
    }
    
    let fromPlaylist = SongListType.fromPlaylist.rawValue
    
    let fromAlbums = SongListType.fromAlbums.rawValue
    
    let fromAlbumsSearch = SongListType.fromAlbumsSearch.rawValue
    
    let fromArtist = SongListType.fromArtist.rawValue
    
    var state: Int?
    
    var songTracksInfo = [SongsSearchInfo]()
    
    var playlistTracks = [SongsSearchInfo]()
    
    var playlist: PlaylistsChartsInfo?
    
    var albumTracks = [SongsSearchInfo]()
    
    var album: AlbumsChartsInfo?
    
    var albumID: String?
    
    var albumURL: String?
    
    var artistID: String?
    
    var artistURL: String?
    
    var artistAlbums = [ArtistsSearchInfo]()
    
    var artistAlbumsData = [ArtistsAlbumsData]()
    
    var artistAllAlbumsTrack = [SongsSearchInfo]()
    
    var isFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songListTableView.dataSource = self
        
        songListTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if state == fromPlaylist {
            
            MusicManager.sharedInstance.fetchPlaylistsTracks(with: playlist!.id) { tracks in
                self.playlistTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.playlist?.attributes?.artwork?.url, let width = self.playlist?.attributes?.artwork?.width, let height = self.playlist?.attributes?.artwork?.height {
                        
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.kf.setImage(with: URL(string: pictureURL))
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
        }
        else if state == fromAlbums {
            
            guard let albumID = album?.id else {
                return
            }
            
            MusicManager.sharedInstance.fetchAlbumsTracks(with: albumID) { tracks in
                
                self.albumTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.album?.attributes?.artwork?.url, let width = self.album?.attributes?.artwork?.width, let height = self.album?.attributes?.artwork?.height {
                        
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.kf.setImage(with: URL(string: pictureURL))
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
        }
        else if state == fromAlbumsSearch {
            
            guard let albumID = albumID else { return }
            
            MusicManager.sharedInstance.fetchAlbumsTracks(with: albumID) { tracks in
                
                self.albumTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.albumTracks[0].attributes?.artwork?.url, let width = self.albumTracks[0].attributes?.artwork?.width, let height = self.albumTracks[0].attributes?.artwork?.height {
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.kf.setImage(with: URL(string: pictureURL))
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
            
        }
        else if state == fromArtist {
            
            artistAlbums = []
            
            artistAlbumsData = []
            
            artistAllAlbumsTrack = []
            
            guard let artistID = artistID else {
                return
            }
            
            MusicManager.sharedInstance.fetchArtistsAlbums(with: artistID, completion: { result in
                
                self.artistAlbums = result
                
                guard let data = result[0].relationships?.albums.data else { return }
                
                self.artistAlbumsData = data
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.artistAlbums[0].attributes?.artwork?.url, let width = self.artistAlbums[0].attributes?.artwork?.width, let height = self.artistAlbums[0].attributes?.artwork?.height {
                        
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.kf.setImage(with: URL(string: pictureURL))
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
                
                self.artistAlbumsData.forEach { album in
                    
                    MusicManager.sharedInstance.fetchAlbumsTracks(with: album.id!) { tracks in
                        
                        self.artistAllAlbumsTrack += tracks
                        
                        self.songListTableView.reloadData()
                        
                    }
                }
            })
            
        }
        else {
            
            print("Unknown state")
        }
        
        configureButton()
    }
    
    @IBAction func addToFavoriteButton(_ sender: UIButton) {
        
        if isFavorite {
            
            switch state {
                
            case fromPlaylist:
                
                guard let playlist = playlist else { return }
                
                let playlistID = playlist.id
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.playlists, id: playlistID)
                
                
            case fromAlbums:
                
                guard let album = album else { return }
                
                let albumID = album.id
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
                
                
            case fromAlbumsSearch:
                
                guard let albumID = self.albumID else { return }
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
                
            case fromArtist:
                
                guard let artistID = self.artistID else { return }
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.artists, id: artistID)
                
            default:
                
                print("Unknown state for configuring song data")
            }
            
            self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            
            isFavorite = false
            
        }
        else {
            
            switch state {
                
            case fromPlaylist:
                
                guard let playlist = playlist else { return }
                
                let playlistID = playlist.id
                
                FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.playlists, id: playlistID)
                    
                self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                
            case fromAlbums:
                
                guard let album = album else { return }
                
                let albumID = album.id
                
                FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
                
            case fromAlbumsSearch:
                
                guard let albumID = self.albumID else { return }
                
                FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
                
                self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                
                
            case fromArtist:
                
                guard let artistID = self.artistID else { return }
                
                FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.artists, id: artistID)
                
                self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                
                
            default:
                
                print("Unknown state for configuring song data")
            }
            
            self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            isFavorite = true
        }
    }
    
    func changeFavoriteButton() {
        
        DispatchQueue.main.async {

            if self.isFavorite {

                DispatchQueue.main.async {
                    
                    self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                
            }
            else {
                
                DispatchQueue.main.async {
                    
                    self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }
        
    }
    
    func configureButton() {
        
        switch state {
            
        case fromPlaylist:
            
            guard let playlist = playlist else { return }
            
            let playlistID = playlist.id
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.playlists) { result in
                
                result.id.forEach { id in
                    
                    if playlistID == id {
                        
                        self.isFavorite = true
                    }
                }
                
                self.changeFavoriteButton()
            }
            
        case fromAlbums:
            
            guard let album = album else { return }
            
            let albumID = album.id
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in
                
                result.id.forEach { id in

                    if albumID == id {
                        
                        self.isFavorite = true
                    }
                }
                
                self.changeFavoriteButton()
            }
            
        case fromAlbumsSearch:
            
            guard let albumID = self.albumID else { return }
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in
                
                result.id.forEach { id in

                    if albumID == id {
                        
                        self.isFavorite = true
                    }
                }
                
                self.changeFavoriteButton()
            }
            
        case fromArtist:
            
            guard let artistID = self.artistID else { return }
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.artists) { result in
                
                result.id.forEach { id in

                    if self.artistID == id {
                        
                        self.isFavorite = true
                    }
                }
                
                self.changeFavoriteButton()
            }
            
        default:
            
            print("Unknown state for favorite state")
        }
        
    }
    
    @IBAction func sharedButton(_ sender: UIButton) {
        
        var url: URL?
        
        switch state {
            
        case fromPlaylist:
            
            guard let playlistURL = playlist?.attributes?.url else { return }
            
            url = URL(string: playlistURL)
            
        case fromAlbums:
            
            guard let albumURL = album?.attributes?.url else { return }
            
            url = URL(string: albumURL)
            
        case fromAlbumsSearch:
            
            guard let albumURL = albumURL else { return }
            
            url = URL(string: albumURL)
            
        case fromArtist:
            
            guard let artistURL = self.artistURL else { return }
            
            url = URL(string: artistURL)
            
        default:
            
            print("Unknown state for configuring song data")
        }
        
        guard let url = url else {
            
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func configureSongData(state: Int, indexPath: IndexPath) {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
            
            var songs: SongsSearchInfo?
            
            switch state {
                
            case fromPlaylist:
                
                songs = self.playlistTracks[indexPath.row]
                
            case fromAlbums, fromAlbumsSearch:
                
                songs = self.albumTracks[indexPath.row]
                
            case fromArtist:
                
                songs = self.artistAllAlbumsTrack[indexPath.row]
                
            default:
                
                print("Unknown state for configuring song data")
            }
            
            
            playSongVC.songs = songs
            
            self.navigationController?.pushViewController(playSongVC, animated: true)
        }
    }
    
}

extension SongListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if state == fromPlaylist {
            
            return self.playlistTracks.count
        }
        else if state == fromAlbums || state == fromAlbumsSearch {
            
            return self.albumTracks.count
        }
        else if state == fromArtist {
            
            guard !artistAlbums.isEmpty else {
                
                return 0
            }
            
            return artistAllAlbumsTrack.count
        }
        else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongListTableViewCell.identifier, for: indexPath) as? SongListTableViewCell else {
            
            fatalError("Cannot create song list table view cell")
        }
        
        if state == fromPlaylist {
            
            cell.configureCell(data: playlistTracks, indexPath: indexPath)
            
            return cell
            
        }
        else if state == fromAlbums || state == fromAlbumsSearch {
            
            cell.configureCell(data: albumTracks, indexPath: indexPath)
            
            return cell
            
        }
        else if state == fromArtist {
            
            guard !artistAlbumsData.isEmpty && !artistAllAlbumsTrack.isEmpty else {
                
                return UITableViewCell()
            }
            cell.configureCell(data: artistAllAlbumsTrack, indexPath: indexPath)
            
            return cell
            
        }
        else {
            
            return UITableViewCell()
        }
        
    }
}

extension SongListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let state = state else { return }
        
        configureSongData(state: state, indexPath: indexPath)

    }
}
