//
//  PlaySongViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/31.
//

import UIKit
import Kingfisher
import AVFoundation
import AVFAudio

class PlaySongViewController: UIViewController {

    static let storyboardID = "PlaySongVC"
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var musicSlider: UISlider!
    
    var songs: SongsSearchInfo?
    
    var currentMusicIndex: Int = 0
    
    var previousMusicIndex: Int = 0
    
    var nextMusicIndex: Int = 0
    
    let player = AVPlayer()
    
    var playerLooper: AVPlayerLooper?
    
    var playerItem: AVPlayerItem?
    
    var isMusicPlaying: Bool = false
    
    var currentTime: Double = 0
    
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
                    
                    let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                    
                    self.songImage.kf.setImage(with: URL(string: pictureURL))
                    
                }
            }
        }
        
//        if let songs = songsFromPlaylists {
//
//            DispatchQueue.main.async {
//
//                self.songLabel.text = songs.attributes?.name
//                self.singerLabel.text = songs.attributes?.artistName
//
//                if let artworkURL = songs.attributes?.artwork?.url,
//                   let width = songs.attributes?.artwork?.width,
//                   let height = songs.attributes?.artwork?.height {
//
//                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
//
//                    self.songImage.kf.setImage(with: URL(string: pictureURL))
//
//                }
//            }
//        }
//
//        if let songs = songsFromAlbums {
//
//            DispatchQueue.main.async {
//
//                self.songLabel.text = songs.attributes?.name
//                self.singerLabel.text = songs.attributes?.artistName
//
//                if let artworkURL = songs.attributes?.artwork?.url,
//                   let width = songs.attributes?.artwork?.width,
//                   let height = songs.attributes?.artwork?.height {
//
//                    let pictureURL = self.musicManager.fetchPicture(url: artworkURL, width: String(width), height: String(height))
//
//                    self.songImage.kf.setImage(with: URL(string: pictureURL))
//
//                }
//            }
//        }
    }
    
    func playMusic(url: String) {
        
        print("Play")
        
        isMusicPlaying = true
        
        let musicURL = URL.init(fileURLWithPath: url)
        
        playerItem = AVPlayerItem(url: musicURL)
        
        player.replaceCurrentItem(with: playerItem)
        
        let time = CMTime(seconds: self.currentTime, preferredTimescale: 1)
        
        player.seek(to: time)

        
        player.play()
    }
    
    
    func pauseMusic() {
        
        print("Pause")
        
        isMusicPlaying = false
        
        currentTime = player.currentTime().seconds
        
        print("-----\(currentTime)")
        player.pause()
    }
    
    @IBAction func previousButton(_ sender: UIButton) {
        
        self.currentTime = 0
        
//        guard musicItems != nil else {
//
//            return
//
//        }
        
        if previousMusicIndex - 1 >= 0 {
            
            currentMusicIndex = previousMusicIndex - 1
            
            previousMusicIndex -= 1
            
            nextMusicIndex = currentMusicIndex + 1
        }
        
//        print(musicItems![currentMusicIndex].attributes?.previews![0].url)
//        guard let url = musicItems![currentMusicIndex].attributes?.previews![0].url else {
//
//            return
//
//        }
        
        //playMusic(url: url)
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        self.currentTime = 0
        
        pauseMusic()
        
        print("next")
        
//        guard musicItems != nil else {
//
//            return
//
//        }
        
//        if currentMusicIndex + 1 < musicItems!.count {
//
//            currentMusicIndex += 1
//
//            nextMusicIndex = currentMusicIndex + 1
//
//            previousMusicIndex = currentMusicIndex - 1
//        }
        
//        print(musicItems![currentMusicIndex].attributes?.previews![0].url)
//        guard let url = musicItems![currentMusicIndex].attributes?.previews![0].url else {
//
//            return
//
//        }
        
        //playMusic(url: url)
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
        if isMusicPlaying == false {
            
//            guard musicItems != nil else {
//
//                return
//
//            }
//
//            guard let url = musicItems![currentMusicIndex].attributes?.previews![0].url else {
//
//                return
//
//            }
            
            //playMusic(url: url)
            
            self.setupSlider()
            
        }
        else {
            
            // Pause
            
            pauseMusic()
            
        }
    }
    
    func setupSlider() {
        
        guard let playerItem = playerItem else {
            
            return
        
        }

        let duration : CMTime = playerItem.asset.duration
        
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        musicSlider!.minimumValue = 0
        
        musicSlider!.maximumValue = Float(seconds)
        
        musicSlider!.isContinuous = false
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                        queue: DispatchQueue.main) { (CMTime) -> Void in
            
            if self.player.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                print("====\(currentTime)")
                self.musicSlider.value = Float(currentTime)
                
            }
        }
    }
}
