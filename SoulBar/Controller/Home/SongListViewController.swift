//
//  SongListViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/29.
//

import UIKit

class SongListViewController: UIViewController {
    
    static let storyboardID = "SongListVC"
    
    @IBOutlet weak var songListImage: UIImageView!
    
    @IBOutlet weak var songListTableView: UITableView!
    
    @IBOutlet weak var playView: UIImageView!
    
    @IBOutlet weak var favoriteView: UIImageView!
    
    @IBOutlet weak var sharedView: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    var state: Int?
    
    var playlistTracks = [SongsSearchInfo]()
    
    var playlist: PlaylistsChartsInfo?
    
    var albumTracks = [SongsSearchInfo]()
    
    var album: AlbumsChartsInfo?
    
    var albumID: String?
    
    var albumURL: String?
    
    var albumInfo: AlbumsSearchInfo?
    
    var artistID: String?
    
    var artistURL: String?
    
    var artistInfo: ArtistsSearchInfo?
    
    var artistAlbums = [ArtistsSearchInfo]()
    
    var artistAlbumsData = [ArtistsAlbumsData]()
    
    var artistAllAlbumsTrack = [SongsSearchInfo]()
    
    var isFavorite = false
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        setupConstraints()
        
        configureTapGesture()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        setupMusicData()
        
        configureButton()
    }
    
    private func setupConstraints() {
        
        imageWidthConstraint.constant = UIScreen.main.bounds.height / 3
    }
    
    private func configureTableView() {
        
        songListTableView.dataSource = self
        
        songListTableView.delegate = self
        
        songListTableView.showsVerticalScrollIndicator = false
        
        songListTableView.showsHorizontalScrollIndicator = false
        
    }
    
    private func configureTapGesture() {
        
        let favoriteTap = UITapGestureRecognizer(target: self, action: #selector(addToFavorite))
        favoriteView.addGestureRecognizer(favoriteTap)
        favoriteView.isUserInteractionEnabled = true
        
        let sharedTap = UITapGestureRecognizer(target: self, action: #selector(shared))
        sharedView.addGestureRecognizer(sharedTap)
        sharedView.isUserInteractionEnabled = true
        
        let playTap = UITapGestureRecognizer(target: self, action: #selector(play))
        playView.addGestureRecognizer(playTap)
        playView.isUserInteractionEnabled = true
    }
    
    private func setupMusicData() {
        
        if state == SongListType.fromPlaylist {
            
            DispatchQueue.main.async {
                
                self.songName.text = self.playlist?.attributes?.name
                
                self.artistName.isHidden = true
            }
            
            guard let id = playlist?.id else { return }
            
            MusicManager.sharedInstance.fetchPlaylistsTracks(with: id) { tracks in
                self.playlistTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.playlist?.attributes?.artwork?.url, let width = self.playlist?.attributes?.artwork?.width, let height = self.playlist?.attributes?.artwork?.height {
                        
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.loadImage(pictureURL)
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
        }
        else if state == SongListType.fromAlbums {
            
            DispatchQueue.main.async {
                
                self.songName.text = self.album?.attributes?.name
                
                self.artistName.text = self.album?.attributes?.artistName
            }
            
            guard let albumID = album?.id else { return }
            
            MusicManager.sharedInstance.fetchAlbumsTracks(with: albumID) { tracks in
                
                self.albumTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.album?.attributes?.artwork?.url, let width = self.album?.attributes?.artwork?.width, let height = self.album?.attributes?.artwork?.height {
                        
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.loadImage(pictureURL)
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
        }
        else if state == SongListType.fromAlbumsSearch {
            
            DispatchQueue.main.async {
                
                self.songName.text = self.albumInfo?.attributes?.name
                
                self.artistName.text = self.albumInfo?.attributes?.artistName
            }
            
            guard let albumID = albumID else { return }
            
            MusicManager.sharedInstance.fetchAlbumsTracks(with: albumID) { tracks in
                
                self.albumTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.albumTracks[0].attributes?.artwork?.url, let width = self.albumTracks[0].attributes?.artwork?.width, let height = self.albumTracks[0].attributes?.artwork?.height {
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.loadImage(pictureURL)
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
            
        }
        else if state == SongListType.fromArtist {
            
            DispatchQueue.main.async {
                
                self.songName.text = self.artistInfo?.attributes?.name
                
                self.artistName.isHidden = true
            }
            
            playView.isHidden = true
            
            artistAlbums = []
            
            artistAlbumsData = []
            
            artistAllAlbumsTrack = []
            
            guard let artistID = artistID else { return }
            
            MusicManager.sharedInstance.fetchArtistsAlbums(with: artistID, completion: { result in
                
                self.artistAlbums = result
                
                guard let data = result[0].relationships?.albums?.data else { return }
                
                self.artistAlbumsData = data
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.artistAlbums[0].attributes?.artwork?.url, let width = self.artistAlbums[0].attributes?.artwork?.width, let height = self.artistAlbums[0].attributes?.artwork?.height {
                        
                        let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                        
                        self.songListImage.loadImage(pictureURL)
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
                
                self.artistAlbumsData.forEach { album in
                    
                    guard let id = album.id else { return }
                    
                    MusicManager.sharedInstance.fetchAlbumsTracks(with: id) { tracks in
                        
                        self.artistAllAlbumsTrack += tracks
                        
                        self.songListTableView.reloadData()
                        
                    }
                }
            })
            
        }
    }
    
    private func removeFirebaseData() {
        
        switch state {
            
        case SongListType.fromPlaylist:
            
            guard let playlist = playlist else { return }
            
            let playlistID = playlist.id
            
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.playlists, id: playlistID)
            
        case SongListType.fromAlbums:
            
            guard let album = album else { return }
            
            let albumID = album.id
            
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
            
        case SongListType.fromAlbumsSearch:
            
            guard let albumID = self.albumID else { return }
            
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
            
        case SongListType.fromArtist:
            
            guard let artistID = self.artistID else { return }
            
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.artists, id: artistID)
            
        default:
            
            print("Unknown state for configuring song data")
        }
        
    }
    
    private func addFirebaseData() {
        
        switch state {
            
        case SongListType.fromPlaylist:
            
            guard let playlist = playlist else { return }
            
            let playlistID = playlist.id
            
            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.playlists, id: playlistID)
                
            self.favoriteView.image = UIImage(named: "heart.fill")
            
        case SongListType.fromAlbums:
            
            guard let album = album else { return }
            
            let albumID = album.id
            
            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
            
        case SongListType.fromAlbumsSearch:
            
            guard let albumID = self.albumID else { return }
            
            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.albums, id: albumID)
            
            self.favoriteView.image = UIImage(named: "heart.fill")
            
            
        case SongListType.fromArtist:
            
            guard let artistID = self.artistID else { return }
            
            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.artists, id: artistID)
            
            self.favoriteView.image = UIImage(named: "heart.fill")
            
            
        default:
            
            print("Unknown state for configuring song data")
        }
        
    }
    
    @objc func play() {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
            
            switch state {
                
            case SongListType.fromPlaylist:
    
                playSongVC.songs = self.playlistTracks
                
            case SongListType.fromAlbums, SongListType.fromAlbumsSearch:

                playSongVC.songs = self.albumTracks
                
            case SongListType.fromArtist:
                
                playSongVC.songs = self.artistAllAlbumsTrack
                
            default:
                
                print("Unknown state for configuring song data")
            }
            
            playSongVC.modalPresentationStyle = .fullScreen
            
            self.present(playSongVC, animated: true)
        }
    }
    
    @objc func addToFavorite() {
        
        if KeychainManager.sharedInstance.id == nil {
            
            if let authVC = storyboard?.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as? AppleAuthViewController {
                
                authVC.modalPresentationStyle = .overCurrentContext
                
                self.present(authVC, animated: false)
                
                return
            }
        }
        
        if isFavorite {
            
            removeFirebaseData()
            
            self.favoriteView.image = UIImage(named: "heart")
            
        }
        else {
            
            addFirebaseData()
            
            self.favoriteView.image = UIImage(named: "heart.fill")
            
        }
        
        isFavorite.toggle()
    }
    
    func changeFavoriteButton() {
        
        DispatchQueue.main.async {

            if self.isFavorite {

                DispatchQueue.main.async {
                    
                    self.favoriteView.image = UIImage(named: "heart.fill")
                }
                
            }
            else {
                
                DispatchQueue.main.async {
                    
                    self.favoriteView.image = UIImage(named: "heart")
                }
            }
        }
    }
    
    private func configureButton() {
        
        if KeychainManager.sharedInstance.id == nil { return }
        
        switch state {
            
        case SongListType.fromPlaylist:
            
            guard let playlist = playlist else { return }
            
            let playlistID = playlist.id
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.playlists) { result in
                
                let id = result.id.filter { $0 == playlistID }
                
                if !id.isEmpty { self.isFavorite = true }
                
                self.changeFavoriteButton()
            }
            
        case SongListType.fromAlbums:
            
            guard let album = album else { return }
            
            let albumID = album.id
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in
                
                let id = result.id.filter { $0 == albumID }
                
                if !id.isEmpty { self.isFavorite = true }
                
                self.changeFavoriteButton()
            }
            
        case SongListType.fromAlbumsSearch:
            
            guard let albumID = self.albumID else { return }
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in
                
                let id = result.id.filter { $0 == albumID }
                
                if !id.isEmpty { self.isFavorite = true }
                
                self.changeFavoriteButton()
            }
            
        case SongListType.fromArtist:
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.artists) { result in
                
                let id = result.id.filter { $0 == self.artistID }
                
                if !id.isEmpty { self.isFavorite = true }
                
                self.changeFavoriteButton()
            }
            
        default:
            
            print("Unknown state for favorite state")
        }
        
    }
    
    @objc func shared() {
        
        var url: URL?
        
        switch state {
            
        case SongListType.fromPlaylist:
            
            guard let playlistURL = playlist?.attributes?.url else { return }
            
            url = URL(string: playlistURL)
            
        case SongListType.fromAlbums:
            
            guard let albumURL = album?.attributes?.url else { return }
            
            url = URL(string: albumURL)
            
        case SongListType.fromAlbumsSearch:
            
            guard let albumURL = albumURL else { return }
            
            url = URL(string: albumURL)
            
        case SongListType.fromArtist:
            
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
            
            var songs = [SongsSearchInfo]()
            
            switch state {
                
            case SongListType.fromPlaylist:
                
                songs.append(self.playlistTracks[indexPath.row])
    
                playSongVC.songs = songs
                
            case SongListType.fromAlbums, SongListType.fromAlbumsSearch:
                
                songs.append(self.albumTracks[indexPath.row])
                
                playSongVC.songs = songs
                
            case SongListType.fromArtist:
                
                songs.append(self.artistAllAlbumsTrack[indexPath.row])
                
                playSongVC.songs = songs
                
            default:
                
                print("Unknown state for configuring song data")
            }
            
            playSongVC.modalPresentationStyle = .fullScreen
            
            present(playSongVC, animated: true)
        }
    }
    
}

extension SongListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if state == SongListType.fromPlaylist {
            
            return self.playlistTracks.count
        }
        else if state == SongListType.fromAlbums || state == SongListType.fromAlbumsSearch {
            
            return self.albumTracks.count
        }
        else if state == SongListType.fromArtist {
            
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
        
        if state == SongListType.fromPlaylist {
            
            cell.configureCell(data: playlistTracks, indexPath: indexPath)
            
            return cell
            
        }
        else if state == SongListType.fromAlbums || state == SongListType.fromAlbumsSearch {
            
            cell.configureCell(data: albumTracks, indexPath: indexPath)
            
            return cell
            
        }
        else if state == SongListType.fromArtist {
            
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
