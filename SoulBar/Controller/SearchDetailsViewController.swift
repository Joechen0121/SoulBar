//
//  SearchDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import UIKit

class SearchDetailsViewController: UIViewController {
    
    enum SearchType: Int {
        
        case all = 0
        
        case artist
        
        case song
        
        case album
    }
    
    let allType = SearchType.all.rawValue
    
    let artistType = SearchType.artist.rawValue
    
    let songType = SearchType.song.rawValue
    
    let albumType = SearchType.album.rawValue
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchDetailsTableView: UITableView!
    
    static let storyboardID = "SearchDetailsVC"
    
    var songs = [SongsSearchInfo]()
    
    var albums = [AlbumsSearchInfo]()
    
    var artists = [ArtistsSearchInfo]()
    
    let musicManager = MusicManager()
    
    var buttonTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchDetailsTableView.dataSource = self
        
        searchDetailsTableView.delegate = self
        
        searchTextField.delegate = self
        
        searchDetailsTableView.register(UINib.init(nibName: SearchAllResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchAllResultTableViewCell.identifier)
        
        searchDetailsTableView.register(UINib.init(nibName: SearchArtistsResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchArtistsResultTableViewCell.identifier)
        
        searchDetailsTableView.register(UINib.init(nibName: SearchSongsResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchSongsResultTableViewCell.identifier)
        
        searchDetailsTableView.register(UINib.init(nibName: SearchAlbumsResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchAlbumsResultTableViewCell.identifier)
        
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        
        self.buttonTag = sender.tag
        
        guard let text = searchTextField.text else { return }
        
        self.albums = []
        self.songs = []
        self.artists = []
        
        if buttonTag == allType {
            
            musicManager.searchArtists(term: text, limit: 10) { artists in
                
                self.artists = artists
                
                self.musicManager.searchSongs(term: text, limit: 10) { songs in

                    self.songs = songs

                    self.musicManager.searchAlbums(term: text, limit: 10) { albums in

                        self.albums = albums

                        DispatchQueue.main.async {

                            self.searchDetailsTableView.reloadData()
                        }
                    }
                }
            }
        }
        else if buttonTag == artistType {
            
            musicManager.searchArtists(term: text, limit: 25) { artists in
                
                self.artists = artists
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }
        }
        
        else if buttonTag == songType {
            
            musicManager.searchSongs(term: text, limit: 25) { songs in

                self.songs = songs

                DispatchQueue.main.async {

                    self.searchDetailsTableView.reloadData()
                }
            }
        }
        else if buttonTag == albumType {
            
            musicManager.searchAlbums(term: text, limit: 25) { albums in

                self.albums = albums

                DispatchQueue.main.async {

                    self.searchDetailsTableView.reloadData()
                }
            }
        }

    }
    
}

extension SearchDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if buttonTag == allType {
            
            guard !self.artists.isEmpty && !self.songs.isEmpty && !self.albums.isEmpty else { return "" }
            
            if section == 0 {
                
                return "Singer"
            }
            else if section == 1 {
                
                return "Songs"
            }
            else if section == 2 {
                
                return "Albums"
            }
        }
        
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if buttonTag == allType {
            
            return 3
        }
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if buttonTag == allType {
            
            if section == 0 {
                
                return artists.count
            }
            else if section == 1 {
                
                return songs.count
            }
            else if section == 2 {
                
                return albums.count
            }
            
        }
        else if buttonTag == artistType {
            
            return artists.count
        }
        else if buttonTag == songType {
            
            return songs.count
        }
        else if buttonTag == albumType {
            
            return albums.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if buttonTag == allType {
            
            if indexPath.section == 0 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {

                    fatalError("Cannot create search details cell")
                }
                
                cell.singerName.text = self.artists[indexPath.row].attributes?.name
                
                if let artworkURL = self.artists[indexPath.row].attributes?.artwork?.url,
                   let width = self.artists[indexPath.row].attributes?.artwork?.width,
                   let height = self.artists[indexPath.row].attributes?.artwork?.height {
                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
                    cell.allImage.kf.setImage(with: URL(string: pictureURL))
                    
                }

                return cell
            }
            else if indexPath.section == 1 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {

                    fatalError("Cannot create search details cell")
                }
                
                cell.singerName.text = self.songs[indexPath.row].attributes?.name
                
                if let artworkURL = self.songs[indexPath.row].attributes?.artwork?.url,
                   let width = self.songs[indexPath.row].attributes?.artwork?.width,
                   let height = self.songs[indexPath.row].attributes?.artwork?.height
                {
                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
                    cell.allImage.kf.setImage(with: URL(string: pictureURL))
                    
                }

                return cell
            }
            else if indexPath.section == 2 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {

                    fatalError("Cannot create search details cell")
                }
                
                cell.singerName.text = self.albums[indexPath.row].attributes?.name
                
                if let artworkURL = self.albums[indexPath.row].attributes?.artwork?.url,
                   let width = self.albums[indexPath.row].attributes?.artwork?.width,
                   let height = self.albums[indexPath.row].attributes?.artwork?.height {
                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
                    cell.allImage.kf.setImage(with: URL(string: pictureURL))
                    
                }

                return cell
            }

        }
    
        else if buttonTag == artistType {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchArtistsResultTableViewCell.identifier, for: indexPath) as? SearchArtistsResultTableViewCell else {

                fatalError("Cannot create search details cell")
            }
            
            cell.artistLabel.text = self.artists[indexPath.row].attributes?.name
            
            if let artworkURL = self.artists[indexPath.row].attributes?.artwork?.url,
               let width = self.artists[indexPath.row].attributes?.artwork?.width,
               let height = self.artists[indexPath.row].attributes?.artwork?.height {
                let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
        
                cell.artistImage.kf.setImage(with: URL(string: pictureURL))
                
            }

            return cell
            
        }
        else if buttonTag == songType {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchSongsResultTableViewCell.identifier, for: indexPath) as? SearchSongsResultTableViewCell else {

                fatalError("Cannot create search details cell")
            }
            
            cell.songLabel.text = self.songs[indexPath.row].attributes?.name
            
            if let artworkURL = self.songs[indexPath.row].attributes?.artwork?.url,
               let width = self.songs[indexPath.row].attributes?.artwork?.width,
               let height = self.songs[indexPath.row].attributes?.artwork?.height {
                let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
        
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }

            return cell
        }
        else if buttonTag == albumType {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAlbumsResultTableViewCell.identifier, for: indexPath) as? SearchAlbumsResultTableViewCell else {

                fatalError("Cannot create search details cell")
            }
            
            cell.albumName.text = self.albums[indexPath.row].attributes?.name
            cell.singerName.text = self.albums[indexPath.row].attributes?.artistName
            if let artworkURL = self.albums[indexPath.row].attributes?.artwork?.url,
               let width = self.albums[indexPath.row].attributes?.artwork?.width,
               let height = self.albums[indexPath.row].attributes?.artwork?.height {
                let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
        
                cell.albumImage.kf.setImage(with: URL(string: pictureURL))
                
            }

            return cell
        }
        
        return UITableViewCell()
        
    }
    
}

extension SearchDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text else {
            
            return
            
        }
        if buttonTag == allType {
            
            musicManager.searchArtists(term: text, limit: 10) { artists in
                
                self.artists = artists
                
                self.musicManager.searchSongs(term: text, limit: 10) { songs in

                    self.songs = songs

                    self.musicManager.searchAlbums(term: text, limit: 10) { albums in

                        self.albums = albums

                        DispatchQueue.main.async {

                            self.searchDetailsTableView.reloadData()
                        }
                    }
                }
            }
        }
        else if buttonTag == artistType {
            
            musicManager.searchArtists(term: text, limit: 25) { artists in
                
                self.artists = artists
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }
        }
        
        else if buttonTag == songType {
            
            musicManager.searchSongs(term: text, limit: 25) { songs in

                self.songs = songs
                
                DispatchQueue.main.async {

                    self.searchDetailsTableView.reloadData()
                }
            }
        }
        else if buttonTag == albumType {
            
            musicManager.searchAlbums(term: text, limit: 25) { albums in
                
                self.albums = albums
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }
        }
    }
}

extension SearchDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if buttonTag == artistType {
            if let songlistVC = self.storyboard!.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {

                songlistVC.state = 3

                songlistVC.artistID = artists[indexPath.row].id

                self.navigationController!.pushViewController(songlistVC, animated: true)
            }
        }
        else if buttonTag == songType {

//            if let songlistVC = self.storyboard!.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {
//
//                songlistVC.state = 2
//
//                songlistVC.albumID = albums[indexPath.row].id
//
//                self.navigationController!.pushViewController(songlistVC, animated: true)
//            }
        }
        else if buttonTag == albumType {

            if let songlistVC = self.storyboard!.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {

                songlistVC.state = 2

                songlistVC.albumID = albums[indexPath.row].id

                self.navigationController!.pushViewController(songlistVC, animated: true)
            }
        }
    }
}
