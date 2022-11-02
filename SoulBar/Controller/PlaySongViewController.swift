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
    
    var isMusicPlaying = false
    
    var currentTime: Double = 0
    
    var isFavorite = false
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureSong()
        
        configureButton()
    }
    
    func configureButton() {
        
        guard let songs = songs else {
            
            return
            
        }

        guard let songID = songs.id else { return }

        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: "songs") { result in
            
            result.id.forEach { id in

                if songID == id {
                    
                    self.isFavorite = true
                }
            }
            
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
        
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard let songsID = songs?.id else {
            return
        }
        
        if isFavorite {
    
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: "songs", id: songsID)
            
            self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            
            isFavorite = false

        }
        else {

            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: "songs", id: songsID)
                
            self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            isFavorite = true

        }
        

    }
    
    @IBAction func sharedButton(_ sender: UIButton) {
        
        guard let songURL = songs?.attributes?.previews?[0].url else { return }
    
        let activityVC = UIActivityViewController(activityItems: [songURL], applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func configureSong() {
        
        if let songs = songs {
    
            DispatchQueue.main.async {
        
                self.songLabel.text = songs.attributes?.name
                
                self.singerLabel.text = songs.attributes?.artistName
                
                if let artworkURL = songs.attributes?.artwork?.url, let width = songs.attributes?.artwork?.width, let height = songs.attributes?.artwork?.height {
                    
                    let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                    
                    self.songImage.kf.setImage(with: URL(string: pictureURL))
                    
                }
            }
        }
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
        
        if previousMusicIndex - 1 >= 0 {
            
            currentMusicIndex = previousMusicIndex - 1
            
            previousMusicIndex -= 1
            
            nextMusicIndex = currentMusicIndex + 1
        }

        // playMusic(url: url)
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        self.currentTime = 0
        
        pauseMusic()
        
        print("next")
        
        
//        if currentMusicIndex + 1 < musicItems!.count {
//
//            currentMusicIndex += 1
//
//            nextMusicIndex = currentMusicIndex + 1
//
//            previousMusicIndex = currentMusicIndex - 1
//        }
        
        // playMusic(url: url)
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        
        if isMusicPlaying == false {
            
            guard let url = songs?.attributes?.previews?[0].url else { return }
            
            playMusic(url: url)
            
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

        let duration: CMTime = playerItem.asset.duration
        
        let seconds: Float64 = CMTimeGetSeconds(duration)
        
        musicSlider!.minimumValue = 0
        
        musicSlider!.maximumValue = Float(seconds)
        
        musicSlider!.isContinuous = false
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { _ in
            
            if self.player.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                print("====\(currentTime)")
                self.musicSlider.value = Float(currentTime)
                
            }
        }
    }
}

