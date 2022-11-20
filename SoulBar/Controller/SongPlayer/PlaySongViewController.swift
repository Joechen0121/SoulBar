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

    @IBOutlet weak var favoriteView: UIImageView!
    
    @IBOutlet weak var addToListView: UIImageView!
    
    @IBOutlet weak var minTimeLabel: UILabel!
    
    @IBOutlet weak var maxTimeLabel: UILabel!
    
    @IBOutlet weak var songImageWidthConstraint:
    NSLayoutConstraint!
    
    @IBOutlet weak var songImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var songImageTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var previousImage: UIImageView!
    
    @IBOutlet weak var playPauseImage: UIImageView!
    
    @IBOutlet weak var nextImage: UIImageView!
    
    @IBOutlet weak var volumeSilder: UISlider!
    
    @IBOutlet weak var sharedView: UIImageView!
    
    var songs: [SongsSearchInfo]?
    
    var currentItemIndex: Int = 0
    
    var previousItemIndex: Int = 0
    
    var nextItemIndex: Int = 0
    
    var playerLooper: AVPlayerLooper?
    
    var currentTime: Double = 0
    
    var isFavorite = false
    
    var status: PlayState = .pause
    
    var rule: PlayRule = .loop
    
    var sliderTrackLayer = CAGradientLayer()
    
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
        
        songImageWidthConstraint.constant = UIScreen.main.bounds.height / 1.5

        songImageHeightConstraint.constant = UIScreen.main.bounds.height / 3

        songImageTopConstraint.constant = UIScreen.main.bounds.height / 20

        let previousTap = UITapGestureRecognizer(target: self, action: #selector(previousButton(_:)))
        previousImage.isUserInteractionEnabled = true
        previousImage.addGestureRecognizer(previousTap)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(playPauseButton(_:)))
        playPauseImage.isUserInteractionEnabled = true
        playPauseImage.addGestureRecognizer(playPauseTap)
        
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(nextButton(_:)))
        nextImage.isUserInteractionEnabled = true
        nextImage.addGestureRecognizer(nextTap)
        
        let addToListTap = UITapGestureRecognizer(target: self, action: #selector(addToList))
        addToListView.isUserInteractionEnabled = true
        addToListView.addGestureRecognizer(addToListTap)
        
        let favoriteTap = UITapGestureRecognizer(target: self, action: #selector(addToFavorite))
        favoriteView.isUserInteractionEnabled = true
        favoriteView.addGestureRecognizer(favoriteTap)
        
        let sharedTap = UITapGestureRecognizer(target: self, action: #selector(shared))
        sharedView.isUserInteractionEnabled = true
        sharedView.addGestureRecognizer(sharedTap)
        
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
            
            playPauseImage.image = UIImage(named: "pause.fill")
            
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
        
        configureButtonView()
        
        configureView()
        
        configureButton(currentItemIndex: currentItemIndex)
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //PlaySongManager.sharedInstance.removeTimeObserve()
    }
    
    @IBAction func playVideoButton(_ sender: UIButton) {
        
        PlaySongManager.sharedInstance.pauseMusic()
        
        playPauseImage.image = UIImage(named: "play.fill")
        
        if let videoVC = self.storyboard?.instantiateViewController(withIdentifier: PlayVideoViewController.storyboardID) as? PlayVideoViewController {
            
            if let sheetPresentationController = videoVC.sheetPresentationController {
                sheetPresentationController.detents = [.large()]
                
                sheetPresentationController.prefersGrabberVisible = true
    
                present(videoVC, animated: true)
            }
        }
    }
    
    @IBAction func songSlider(_ sender: UISlider) {
        
        PlaySongManager.sharedInstance.seekTo(Double(sender.value))
        
    }
    
    @IBAction func setSongVolumeSlider(_ sender: UISlider) {
        
        PlaySongManager.sharedInstance.player.volume = sender.value

        volumeSilder.value = sender.value
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    @objc func addToList() {
        
        if KeychainManager.sharedInstance.id == nil {
            let authVC = storyboard!.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as! AppleAuthViewController
            authVC.modalPresentationStyle = .overCurrentContext
            self.present(authVC, animated: false)
            
            return
        }
        
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
    
    func configureButtonView() {
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .playing {
            
            playPauseImage.image = UIImage(named: "pause.fill")
            
        }
        else {
            
            playPauseImage.image = UIImage(named: "play.fill")
        }
    }
    
    func configureView() {
        
        volumeSilder.value = PlaySongManager.sharedInstance.player.volume
        
        musicSlider.value = Float(Double(PlaySongManager.sharedInstance.currentTime) / Double( PlaySongManager.sharedInstance.position.duration))
        
        minTimeLabel.text = String(format: "%02d:%02d", Int(PlaySongManager.sharedInstance.currentTime) / 60, Int(PlaySongManager.sharedInstance.currentTime) % 60)
        
        maxTimeLabel.text = String(format: "%02d:%02d", Int( PlaySongManager.sharedInstance.position.duration) / 60, Int( PlaySongManager.sharedInstance.position.duration) % 60)
    }
    
    func configureButton(currentItemIndex: Int) {
        
        if KeychainManager.sharedInstance.id == nil { return }
        
        guard let songs = songs else {
            
            return
            
        }
        
        guard KeychainManager.sharedInstance.id != nil else { return }

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
        
    }
    
    @objc func addToFavorite() {
        
        if KeychainManager.sharedInstance.id == nil {
            let authVC = storyboard!.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as! AppleAuthViewController
            authVC.modalPresentationStyle = .overCurrentContext
            self.present(authVC, animated: false)
            
            return
        }
        
        guard let songsID = songs?[self.currentItemIndex].id else {
            return
        }
        
        if isFavorite {
    
            FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.songs, id: songsID)
            
            self.favoriteView.image = UIImage(named: "heart")
            
            isFavorite = false

        }
        else {

            FirebaseFavoriteManager.sharedInstance.addFavoriteMusicData(with: K.FStore.Favorite.songs, id: songsID)
                
            self.favoriteView.image = UIImage(named: "heart.fill")
            
            isFavorite = true

        }
        

    }
    
    @objc func shared() {
        
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
    
    func configureCurrentSong() {
        
        guard let songs = PlaySongManager.sharedInstance.songs, !songs.isEmpty else { return }
        
        guard let song = PlaySongManager.sharedInstance.songs?[PlaySongManager.sharedInstance.current], let url = song.attributes?.previews?[0].url else {
            
            return
        }
        
        DispatchQueue.main.async {
            
            self.songLabel.text = song.attributes?.name
            
            self.singerLabel.text = song.attributes?.artistName
            
            if let artworkURL = song.attributes?.artwork?.url, let width = song.attributes?.artwork?.width, let height = song.attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                self.songImage.kf.setImage(with: URL(string: pictureURL))
            }
        }
    }
    
    
    @objc func previousButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }

        PlaySongManager.sharedInstance.closePlayer()
        
        currentItemIndex = (currentItemIndex + songs.count - 1) % songs.count
        
        selectData(index: currentItemIndex, isFromMiniPlayer: false)
        
        configureSong()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
    }
    
    @objc func nextButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }

        PlaySongManager.sharedInstance.closePlayer()

        currentItemIndex = (currentItemIndex + songs.count + 1) % songs.count
        
        selectData(index: currentItemIndex, isFromMiniPlayer: false)
        
        configureSong()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
        
    }
    
    @objc func playPauseButton(_ sender: UIButton) {
  
        guard let songs = songs else {
            return
        }
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .paused {
            
            PlaySongManager.sharedInstance.playMusic(url: (songs[self.currentItemIndex].attributes?.previews![0].url)!)
            
            playPauseImage.image = UIImage(named: "pause.fill")

            status = .play
        }
        else {
            
            PlaySongManager.sharedInstance.pauseMusic()
            
            playPauseImage.image = UIImage(named: "play.fill")
            
            status = .pause
        }
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
        
    }
    
    func selectData(index: Int, isFromMiniPlayer: Bool) {
        print(#function)
        guard let songs = songs else { return }

        currentItemIndex = index
    
        singerLabel.text = songs[self.currentItemIndex].attributes?.artistName
        songLabel.text = songs[self.currentItemIndex].attributes?.name
        
        PlaySongManager.sharedInstance.current = currentItemIndex
        PlaySongManager.sharedInstance.maxCount = songs.count

        if let url = songs[self.currentItemIndex].attributes?.previews?[0].url, let songURL = URL(string: url) {
            
            if isFromMiniPlayer == true {

                configureCurrentSong()
                
            }
            else {
                print("setup player")
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
            
            configureCurrentSong()
            
            NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
            
        case .PlayerDidToPlayNotification:

            playPauseImage.image = UIImage(named: "pause.fill")
            
            status = .play
            
            NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
            
        case .PlayerFailedNotification:
            
            let alert = UIAlertController(title: "錯誤", message: "無法播放", preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        case .PauseNotification:
    
            playPauseImage.image = UIImage(named: "play.fill")
            
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
                    
                    playPauseImage.image = UIImage(named: "play.fill")

                    status = .unowned
                }
            }

        default:
            break
        }
    }
}
