//
//  PlaySongViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/31.
//

import UIKit
import Kingfisher

class PlaySongViewController: UIViewController {

    static let storyboardID = "PlaySongVC"
    
    @IBOutlet weak var songImage: UIImageView!
    
    let musicManager = MusicManager()
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var musicSlider: UISlider!
    
    var songs: SongsSearchInfo?

    var songsFromPlaylists: PlaylistsTracksData?
    
    var songsFromAlbums: AlbumsTracksData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureSong()
    }
    
    func configureSong() {
        
        if let songs = songs {
            print("mmm")
            DispatchQueue.main.async {
        
                self.songLabel.text = songs.attributes?.name
                self.singerLabel.text = songs.attributes?.artistName
                
                if let artworkURL = songs.attributes?.artwork?.url,
                   let width = songs.attributes?.artwork?.width,
                   let height = songs.attributes?.artwork?.height {
                    
                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                    
                    self.songImage.kf.setImage(with: URL(string: pictureURL))
                    
                }
            }
        }
        
        if let songs = songsFromPlaylists {

            DispatchQueue.main.async {
        
                self.songLabel.text = songs.attributes?.name
                self.singerLabel.text = songs.attributes?.artistName
                
                if let artworkURL = songs.attributes?.artwork?.url,
                   let width = songs.attributes?.artwork?.width,
                   let height = songs.attributes?.artwork?.height {
                    
                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                    
                    self.songImage.kf.setImage(with: URL(string: pictureURL))
                    
                }
            }
        }
        
        if let songs = songsFromAlbums {

            DispatchQueue.main.async {
                
                self.songLabel.text = songs.attributes?.name
                self.singerLabel.text = songs.attributes?.artistName
                
                if let artworkURL = songs.attributes?.artwork?.url,
                   let width = songs.attributes?.artwork?.width,
                   let height = songs.attributes?.artwork?.height {
                    
                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                    
                    self.songImage.kf.setImage(with: URL(string: pictureURL))
                    
                }
            }
        }
    }
    
    
    @IBAction func previousButton(_ sender: UIButton) {
        
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
    }
}
