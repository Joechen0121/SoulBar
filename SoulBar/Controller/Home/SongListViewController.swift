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
    
    let musicManager = MusicManager()
    
    var state: Int?
    
    var songTracksInfo = [SongsSearchInfo]()
    
    var playlistTracks = [PlaylistsTracksData]()
    
    var playlist: PlaylistsChartsInfo?
    
    var albumTracks = [AlbumsTracksData]()
    
    var album: AlbumsChartsInfo?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songListTableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if state == 0 {
            
            musicManager.fetchPlaylistsTracks(with: playlist!.id) { tracks in
                self.playlistTracks = tracks

                DispatchQueue.main.async {
                    
                    if let artworkURL = self.playlist?.attributes?.artwork?.url,
                       let width = self.playlist?.attributes?.artwork?.width,
                       let height = self.playlist?.attributes?.artwork?.height
                        
                    {
                        let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                        self.songListImage.kf.setImage(with: URL(string: pictureURL))
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
        }
        else if state == 1 {
            
            musicManager.fetchAlbumsTracks(with: album!.id) { tracks in
                
                self.albumTracks = tracks
                
                DispatchQueue.main.async {
                    
                    if let artworkURL = self.album?.attributes?.artwork?.url,
                       let width = self.album?.attributes?.artwork?.width,
                       let height = self.album?.attributes?.artwork?.height
                        
                    {
                        let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                        self.songListImage.kf.setImage(with: URL(string: pictureURL))
                        
                    }
                    
                    self.songListTableView.reloadData()
                }
            }
        }
        else {
            
            print("Unknown state")
        }
    }
}

extension SongListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if state == 0 {
            
            return self.playlistTracks.count
        }
        else if state == 1 {
            
            return self.albumTracks.count
        }
        else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongListTableViewCell.identifier, for: indexPath) as? SongListTableViewCell else {
            
            fatalError("Cannot create song list table view cell")
        }
        
        if state == 0 {
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artist = playlistTracks[indexPath.row].attributes?.artistName,
               let song = playlistTracks[indexPath.row].attributes?.name,
               let artworkURL = playlistTracks[indexPath.row].attributes?.artwork?.url,
               let width = playlistTracks[indexPath.row].attributes?.artwork?.width,
               let height = playlistTracks[indexPath.row].attributes?.artwork?.height
                
            {
                cell.singerName.text = artist
                cell.songName.text = song
                
                let pictureURL = musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
        
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
                
            }
            
            return cell
            
        }
        else if state == 1 {
            
            cell.songImage.kf.indicatorType = .activity
            
            if let artist = albumTracks[indexPath.row].attributes?.artistName,
               let song = albumTracks[indexPath.row].attributes?.name,
               let artworkURL = albumTracks[indexPath.row].attributes?.artwork?.url,
               let width = albumTracks[indexPath.row].attributes?.artwork?.width,
               let height = albumTracks[indexPath.row].attributes?.artwork?.height
                
            {
                cell.singerName.text = artist
                cell.songName.text = song
                
                let pictureURL = musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
        
                cell.songImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
            
        }
        else {
            
            return UITableViewCell()
        }

    }
    
    
    
}
