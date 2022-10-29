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
        
        searchTextField.delegate = self
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        
        print(sender.tag)
        self.buttonTag = sender.tag
        
        switch buttonTag {
        case SearchType.all.rawValue:
        
            print("123")
            
        case SearchType.artist.rawValue:
            
            musicManager.searchArtists(term: "周杰倫", limit: 25) { artists in
                
                self.artists = artists
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }

        case SearchType.song.rawValue:
            
            musicManager.searchSongs(term: "周杰倫", limit: 25) { songs in
                
                self.songs = songs
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }

        case SearchType.album.rawValue:
            
            musicManager.searchAlbums(term: "周杰倫", limit: 25) { albums in
                
                self.albums = albums
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }

        default:
            
            print("Unknown search type")
        }
    }
    
}

extension SearchDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return artists.count + songs.count + albums.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchDetailsTableViewCell.identifier, for: indexPath) as? SearchDetailsTableViewCell else {
//
//            fatalError("Cannot create search details cell")
//        }
        
//        switch indexPath.section {
//
//        case SearchType.artist.rawValue:
//
//            cell.searchImage =
//
//        case SearchType.song.rawValue:
//
//        case SearchType.album.rawValue:
//
//        default:
//            print("Unknown state")
//        }
        
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
        
        switch buttonTag {
        case SearchType.all.rawValue:
        
            print("123")
            
        case SearchType.artist.rawValue:
            
            musicManager.searchArtists(term: text, limit: 25) { artists in
                
                self.artists = artists
            }

        case SearchType.song.rawValue:
            
            musicManager.searchSongs(term: text, limit: 25) { songs in
                
                self.songs = songs
            }

        case SearchType.album.rawValue:
            
            musicManager.searchAlbums(term: text, limit: 25) { albums in
                
                self.albums = albums
                
                DispatchQueue.main.async {
                    
                    self.searchDetailsTableView.reloadData()
                }
            }

        default:
            
            print("Unknown search type")
        }
    }
}
