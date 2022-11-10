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
import SwiftUI

class PlaySongViewController: UIViewController {

    static let storyboardID = "PlaySongVC"
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var musicSlider: UISlider!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var minTimeLabel: UILabel!
    
    @IBOutlet weak var maxTimeLabel: UILabel!
    
    @IBOutlet weak var songImageAspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var detailButtonWidthStackView: NSLayoutConstraint!
    
    @IBOutlet weak var songImageWidthConstraint:
    NSLayoutConstraint!
    
    var songs: [SongsSearchInfo]?
    
    var currentItemIndex: Int = 0
    
    var previousItemIndex: Int = 0
    
    var nextItemIndex: Int = 0
    
    var playerLooper: AVPlayerLooper?
    
    var isMusicPlaying = false
    
    var currentTime: Double = 0
    
    var isFavorite = false
    
    var status: PlayState = .pause
    
    var rule: PlayRule = .loop
    
    var sliderTrackLayer = CAGradientLayer()
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var songImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var songImageTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playerButtonBottomStackView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(image: UIImage(named: "redBG"))
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let container = UIView()
        container.frame = view.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundImageView.frame = container.bounds
        
        backgroundImageView.alpha = 0.5
        
        container.addSubview(backgroundImageView)
        
        view.insertSubview(container, at: 0)

        PlaySongManager.sharedInstance.setupRemoteTransportControls()
        
        songImageWidthConstraint.constant = UIScreen.main.bounds.height / 2
        
        songImageHeightConstraint.constant = UIScreen.main.bounds.height / 3
        
        songImageTopConstraint.constant = UIScreen.main.bounds.height / 7
        
        detailButtonWidthStackView.constant = UIScreen.main.bounds.width / 3
        
        playerButtonBottomStackView.constant = UIScreen.main.bounds.height / 7
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let songs = songs, !songs.isEmpty else {
            return
        }
        
        PlaySongManager.sharedInstance.songs = songs
        
        if songs.count <= PlaySongManager.sharedInstance.current {
            
            PlaySongManager.sharedInstance.current = 0
        }
        
        if songs[PlaySongManager.sharedInstance.current].attributes?.previews?[0].url == PlaySongManager.sharedInstance.currentSong?.attributes?.previews?[0].url {

            selectData(index: PlaySongManager.sharedInstance.current, isFromMiniPlayer: true)
            
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        else {
            
            PlaySongManager.sharedInstance.currentTime = 0
            
            if songs.count < PlaySongManager.sharedInstance.current {

                selectData(index: 0, isFromMiniPlayer: false)
            }
            else {
    
                selectData(index: PlaySongManager.sharedInstance.current, isFromMiniPlayer: false)
            }
        }
        
        configureSong()
        
        configureButton(currentItemIndex: currentItemIndex)
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)

    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        
            dismiss(animated: true)
    }
    
    @IBAction func addToListButton(_ sender: UIButton) {
        
        if let newListVC = self.storyboard?.instantiateViewController(withIdentifier: NewListDisplayViewController.storyboardID) as? NewListDisplayViewController {
            
            if let sheetPresentationController = newListVC.sheetPresentationController {
                sheetPresentationController.detents = [.medium()]
                
                sheetPresentationController.prefersGrabberVisible = true
                
                sheetPresentationController.preferredCornerRadius = 40.0
                
                guard let songs = songs else {
                    return
                }
                
                newListVC.song = songs[currentItemIndex]
                
                present(newListVC, animated: true)
            }
        }
        
    }
    
    func configureButton(currentItemIndex: Int) {
        
        guard let songs = songs else {
            
            return
            
        }

        guard let songID = songs[currentItemIndex].id else { return }

        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.songs) { result in
            
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
        
        guard let songsID = songs?[self.currentItemIndex].id else {
            return
        }
        
        if isFavorite {
    
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.songs, id: songsID)
            
            self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            
            isFavorite = false

        }
        else {

            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.songs, id: songsID)
                
            self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            isFavorite = true

        }
        

    }
    
    @IBAction func sharedButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }
        
        guard let songURL = songs[self.currentItemIndex].attributes?.previews?[0].url else { return }
    
        let activityVC = UIActivityViewController(activityItems: [songURL], applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func configureSong() {
        
        if let songs = songs {
    
            DispatchQueue.main.async {
        
                self.songLabel.text = songs[self.currentItemIndex].attributes?.name
                
                self.singerLabel.text = songs[self.currentItemIndex].attributes?.artistName
                
                if let artworkURL = songs[self.currentItemIndex].attributes?.artwork?.url, let width = songs[self.currentItemIndex].attributes?.artwork?.width, let height = songs[self.currentItemIndex].attributes?.artwork?.height {
                    
                    let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                    
                    self.songImage.kf.setImage(with: URL(string: pictureURL))
                    
                }
            }
        }
    }
    
    @IBAction func previousButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }

        PlaySongManager.sharedInstance.closePlayer()
        
        currentItemIndex = (currentItemIndex + songs.count - 1) % songs.count
        
        selectData(index: currentItemIndex, isFromMiniPlayer: false)
        
        configureSong()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }

        PlaySongManager.sharedInstance.closePlayer()

        currentItemIndex = (currentItemIndex + songs.count + 1) % songs.count
        
        selectData(index: currentItemIndex, isFromMiniPlayer: false)
        
        configureSong()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
        
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
  
        guard let songs = songs else {
            return
        }
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .paused {
            
            PlaySongManager.sharedInstance.playMusic(url: (songs[self.currentItemIndex].attributes?.previews![0].url)!)
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            status = .play
        }
        else {
            
            PlaySongManager.sharedInstance.pauseMusic()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            status = .pause
        }
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
        
    }
    
    func selectData(index: Int, isFromMiniPlayer: Bool) {
        
        guard let songs = songs else { return }

        currentItemIndex = index
    
        singerLabel.text = songs[self.currentItemIndex].attributes?.artistName
        songLabel.text = songs[self.currentItemIndex].attributes?.name
        
        PlaySongManager.sharedInstance.current = currentItemIndex
        PlaySongManager.sharedInstance.maxCount = songs.count

        if let url = songs[self.currentItemIndex].attributes?.previews?[0].url, let songURL = URL(string: url) {
            
            if isFromMiniPlayer == true {
                
                PlaySongManager.sharedInstance.playMusic(url: url)
                
            }
            else {

                PlaySongManager.sharedInstance.setupPlayer(with: songURL)
            }
            
            PlaySongManager.sharedInstance.currentSong = songs[currentItemIndex]
            
            PlaySongManager.sharedInstance.delegate = self
            
        }
    }
}

extension PlaySongViewController: PlaySongDelegate {
    
    func didUpdatePosition(_ player: AVPlayer?, _ position: PlayerPosition) {
        
        musicSlider.value = Float(position.current) / Float(position.duration)
        minTimeLabel.text = String(format: "%02d:%02d", position.current / 60, position.current % 60)
        maxTimeLabel.text = String(format: "%02d:%02d", position.duration / 60, position.duration % 60)

    }
    
    func didReceiveNotification(player: AVPlayer?, notification: Notification.Name) {

        guard let songs = songs else { return }

        switch notification {
        case .PlayerUnknownNotification:
            
            PlaySongManager.sharedInstance.closePlayer()
            
        case .PlayerReadyToPlayNotification:
            
            NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
            
        case .PlayerDidToPlayNotification:

            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            
            status = .play
            
            NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
            
        case .PlayerFailedNotification:
            
            let alert = UIAlertController(title: "錯誤", message: "無法播放", preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        case .PauseNotification:
    
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
            status = .pause
            
            NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
            
        case .PlayerPlayFinishNotification:

            PlaySongManager.sharedInstance.closePlayer()
            
            switch rule {
                
            case .loop:
                currentItemIndex = (currentItemIndex + songs.count + 1) % songs.count
                selectData(index: currentItemIndex, isFromMiniPlayer: false)
                
            case .random:
                currentItemIndex = Int.random(in: 0..<songs.count)
                selectData(index: currentItemIndex, isFromMiniPlayer: false)
                
            case .single:
                if currentItemIndex + 1 < songs.count {
                    currentItemIndex = (currentItemIndex + songs.count + 1) % songs.count
                    selectData(index: currentItemIndex, isFromMiniPlayer: false)
                }
                else {
                    playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    status = .unowned
                }
            }

        default:
            break
        }
    }
}
