//
//  SearchDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import UIKit
import TransitionButton

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

    @IBOutlet weak var allButton: TransitionButton!
    
    @IBOutlet weak var artistButton: TransitionButton!
    
    @IBOutlet weak var songButton: TransitionButton!
    
    @IBOutlet weak var albumButton: TransitionButton!
    static let storyboardID = "SearchDetailsVC"
    
    var songs = [SongsSearchInfo]()
    
    var albums = [AlbumsSearchInfo]()
    
    var artists = [ArtistsSearchInfo]()
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
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
        
        configureButton()
        
        configureTextField()

    }
    
    func configureTextField() {
        
        searchTextField.clearButtonMode = .always

        searchTextField.leftViewMode = .always

        let searchView = UIImageView(frame: CGRect(x: 10, y: 0, width: 24, height: 24))
        
        let searchImage = UIImage(systemName: "magnifyingglass")

        searchView.image = searchImage
        
        searchView.contentMode = .scaleAspectFit

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        
        view.addSubview(searchView)

        searchTextField.leftView = view
    }
    
    func configureButton() {
        
        buttonStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        
        allButton.backgroundColor = .clear
        allButton.setTitle("All", for: .normal)
        allButton.cornerRadius = 15
        allButton.spinnerColor = .black
        allButton.layer.borderColor = UIColor.black.cgColor
        allButton.layer.borderWidth = 1
        allButton.backgroundColor = UIColor(red: 210 / 255, green: 165 / 255, blue: 109 / 255, alpha: 1)
    
        artistButton.backgroundColor = .clear
        artistButton.setTitle("Artist", for: .normal)
        artistButton.cornerRadius = 15
        artistButton.spinnerColor = .black
        artistButton.layer.borderColor = UIColor.black.cgColor
        artistButton.layer.borderWidth = 1
        
        songButton.backgroundColor = .clear
        songButton.setTitle("Song", for: .normal)
        songButton.cornerRadius = 15
        songButton.spinnerColor = .black
        songButton.layer.borderColor = UIColor.black.cgColor
        songButton.layer.borderWidth = 1
        
        albumButton.backgroundColor = .clear
        albumButton.setTitle("Album", for: .normal)
        albumButton.cornerRadius = 15
        albumButton.spinnerColor = .black
        albumButton.layer.borderColor = UIColor.black.cgColor
        albumButton.layer.borderWidth = 1
    }
    
    func changeButtonColor(buttonTag: Int) {
        
        if buttonTag == allType {
            allButton.backgroundColor = UIColor(red: 210 / 255, green: 165 / 255, blue: 109 / 255, alpha: 1)
            artistButton.backgroundColor = UIColor.clear
            songButton.backgroundColor = UIColor.clear
            albumButton.backgroundColor = UIColor.clear
        }
        else if buttonTag == artistType {
            allButton.backgroundColor = UIColor.clear
            artistButton.backgroundColor = UIColor(red: 210 / 255, green: 165 / 255, blue: 109 / 255, alpha: 1)
            songButton.backgroundColor = UIColor.clear
            albumButton.backgroundColor = UIColor.clear
        }
        else if buttonTag == songType {
            allButton.backgroundColor = UIColor.clear
            artistButton.backgroundColor = UIColor.clear
            songButton.backgroundColor = UIColor(red: 210 / 255, green: 165 / 255, blue: 109 / 255, alpha: 1)
            albumButton.backgroundColor = UIColor.clear
        }
        else if buttonTag == albumType {
            allButton.backgroundColor = UIColor.clear
            artistButton.backgroundColor = UIColor.clear
            songButton.backgroundColor = UIColor.clear
            albumButton.backgroundColor = UIColor(red: 210 / 255, green: 165 / 255, blue: 109 / 255, alpha: 1)
        }
        
    }
    
    @IBAction func searchButton(_ sender: UIButton) {

        self.buttonTag = sender.tag
        
        changeButtonColor(buttonTag: sender.tag)
        
        guard let text = searchTextField?.text else {

            if buttonTag == allType {
                
                allButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.allButton.stopAnimation(animationStyle: .shake)
                }
            }
            else if buttonTag == artistType {
                
                artistButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.artistButton.stopAnimation(animationStyle: .shake)
                }
            }
            else if buttonTag == songType {
                
                songButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.songButton.stopAnimation(animationStyle: .shake)
                }
            }
            else if buttonTag == albumType {
             
                albumButton.startAnimation()
                
                DispatchQueue.main.async {
                    
                    self.albumButton.stopAnimation(animationStyle: .shake)
                }
            }
            
            return
        }

        fetchMusicData(buttonTag: buttonTag, text: text)
    }
    
    func configureSelectedData(state: Int, indexPath: IndexPath) {
        
        if state == allType {
            
            switch indexPath.section {
                
            case 0:
                
                configureSelectedData(state: artistType, indexPath: indexPath)
                
            case 1:
            
                configureSelectedData(state: songType, indexPath: indexPath)
                
            case 2:
                
                configureSelectedData(state: albumType, indexPath: indexPath)
                
            default:
                
                print("Unknown section type")
            }
            
        }
        else if state == artistType {
            if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {

                songlistVC.state = 3

                songlistVC.artistID = artists[indexPath.row].id
                
                songlistVC.artistURL = artists[indexPath.row].attributes?.url
                
                self.navigationController?.pushViewController(songlistVC, animated: true)
            }
        }
        else if state == songType {

            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
                
                var response = [SongsSearchInfo]()
                
                response.append(songs[indexPath.row])
                    
                playSongVC.songs = response
                
                self.navigationController?.pushViewController(playSongVC, animated: true)
            }
        }
        else if state == albumType {

            if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {

                songlistVC.state = 2
                
                songlistVC.albumID = albums[indexPath.row].id
                
                songlistVC.albumURL = albums[indexPath.row].attributes?.url

                self.navigationController?.pushViewController(songlistVC, animated: true)
            }
        }
    }
}

extension SearchDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if buttonTag == allType {
            
            guard !self.artists.isEmpty && !self.songs.isEmpty && !self.albums.isEmpty else { return "" }
            
            if section == 0 {
                
                return "Artists"
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
                
                cell.configureCellArtistsData(data: self.artists, indexPath: indexPath)

                return cell
            }
            else if indexPath.section == 1 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {

                    fatalError("Cannot create search details cell")
                }
                
                cell.configureCellSongsData(data: self.songs, indexPath: indexPath)

                return cell
            }
            else if indexPath.section == 2 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAllResultTableViewCell.identifier, for: indexPath) as? SearchAllResultTableViewCell else {

                    fatalError("Cannot create search details cell")
                }
                
                cell.configureCellAlbumsData(data: self.albums, indexPath: indexPath)

                return cell
            }

        }
    
        else if buttonTag == artistType {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchArtistsResultTableViewCell.identifier, for: indexPath) as? SearchArtistsResultTableViewCell else {

                fatalError("Cannot create search details cell")
            }
            
            guard !self.artists.isEmpty else {

                return UITableViewCell()

            }
            
            cell.configureCellData(data: self.artists, indexPath: indexPath)

            return cell
            
        }
        else if buttonTag == songType {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchSongsResultTableViewCell.identifier, for: indexPath) as? SearchSongsResultTableViewCell else {

                fatalError("Cannot create search details cell")
            }
            
            guard !self.songs.isEmpty else {

                return UITableViewCell()

            }
            
            cell.configureCellData(data: self.songs, indexPath: indexPath)

            return cell
        }
        else if buttonTag == albumType {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAlbumsResultTableViewCell.identifier, for: indexPath) as? SearchAlbumsResultTableViewCell else {

                fatalError("Cannot create search details cell")
            }
            
            guard !self.albums.isEmpty else {

                return UITableViewCell()

            }
            
            cell.configureCellData(data: self.albums, indexPath: indexPath)

            return cell
        }
        
        return UITableViewCell()
        
    }
    
}

extension SearchDetailsViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let text = textField.text else {
            
            return
            
        }

        fetchMusicData(buttonTag: buttonTag, text: text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text else { return }
        
        fetchMusicData(buttonTag: buttonTag, text: text)
    }
}

extension SearchDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        configureSelectedData(state: buttonTag, indexPath: indexPath)

    }
}

extension SearchDetailsViewController {
    
    func fetchMusicData(buttonTag: Int, text: String) {
        
        MusicManager.sharedInstance.stopAllSessions()
        
        if buttonTag == allType {
            
            fetchAllTypes(text: text)
        }
        else if buttonTag == artistType {
    
            fetchArtists(text: text)
        }
        
        else if buttonTag == songType {

            fetchSongs(text: text)
        }
        else if buttonTag == albumType {
    
            fetchAlbums(text: text)
        }
    }
    
    func fetchAllTypes(text: String) {
        
        MusicManager.sharedInstance.searchArtists(term: text, limit: 10) { artists in
            
            self.artists = []
            
            self.artists = artists
            
            MusicManager.sharedInstance.searchSongs(term: text, limit: 10) { songs in
                
                self.songs = []
                
                self.songs = songs
                
                MusicManager.sharedInstance.searchAlbums(term: text, limit: 10) { albums in
                    
                    self.albums = []
                    
                    self.albums = albums

                    DispatchQueue.main.async {
                        
                        self.searchDetailsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func fetchSongs(text: String) {
        
        MusicManager.sharedInstance.searchSongs(term: text, limit: 25) { songs in
            
            self.songs = []
            
            self.songs = songs
            
            DispatchQueue.main.async {
                
                self.searchDetailsTableView.reloadData()
                
            }
        }
        
    }
    
    func fetchArtists(text: String) {
        
        MusicManager.sharedInstance.searchArtists(term: text, limit: 25) { artists in
            
            self.artists = []
            
            self.artists = artists
            
            DispatchQueue.main.async {
                
                self.searchDetailsTableView.reloadData()
            }
        }
        
    }
    
    func fetchAlbums(text: String) {
        
        MusicManager.sharedInstance.searchAlbums(term: text, limit: 25) { albums in
            
            self.albums = []
            
            self.albums = albums
            
            DispatchQueue.main.async {
                
                self.searchDetailsTableView.reloadData()
            }
        }
    }
}
