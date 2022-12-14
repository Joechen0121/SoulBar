//
//  PlaySongViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/31.
//

import UIKit
import AVFoundation
import AVFAudio
import SwiftUI
import FirebaseRemoteConfig

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
    
    @IBOutlet weak var playVideoButton: UIButton!
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    var songs: [SongsSearchInfo]?
    
    var currentItemIndex: Int = 0
    
    var isFavorite = false
    
    var status: PlayState = .pause
    
    var rule: PlayRule = .loop
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBlurBackground()
        
        configureRemoteConfig()
        
        PlaySongManager.sharedInstance.setupRemoteTransportControls()
        
        setupConstraint()

        configureTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkSongsFrom()
        
        configureButtonView()
        
        configureView()
        
        configureButton(currentItemIndex: currentItemIndex)
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)

    }
    
    private func checkSongsFrom() {
        
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
    }
    
    private func configureBlurBackground() {
        
        let backgroundImageView = UIImageView(image: UIImage(named: "redBG"))
        
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let container = UIView()
        
        container.frame = view.bounds
        
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundImageView.frame = container.bounds
        
        backgroundImageView.alpha = 0.5
        
        container.addSubview(backgroundImageView)
        
        view.insertSubview(container, at: 0)

    }
    
    private func setupConstraint() {
        
        songImageWidthConstraint.constant = UIScreen.main.bounds.height / 1.5

        songImageHeightConstraint.constant = UIScreen.main.bounds.height / 3

        songImageTopConstraint.constant = UIScreen.main.bounds.height / 20
    }
    
    private func configureRemoteConfig() {
        
        let settings = RemoteConfigSettings()
        
        settings.minimumFetchInterval = 0
        
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { status, error in
            
            if status == .success {
        
                self.remoteConfig.activate { _, error in
                    
                    guard error == nil else { return }
                    
                    let value = self.remoteConfig.configValue(forKey: "isYoutubeAPITriggered").boolValue
    
                    DispatchQueue.main.async {
                        
                        self.playVideoButton.isHidden = !value
                    }
                }
            }
            else {
                print("Config not fetched")
                
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func configureTapGesture() {
        
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
            
            if let authVC = storyboard?.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as? AppleAuthViewController {
                
                authVC.modalPresentationStyle = .overCurrentContext
                
                self.present(authVC, animated: false)
                
                return
                
            }
        }
        
        if let newListVC = self.storyboard?.instantiateViewController(withIdentifier: NewListDisplayViewController.storyboardID) as? NewListDisplayViewController {
            
            if let sheetPresentationController = newListVC.sheetPresentationController {
                sheetPresentationController.detents = [.medium()]
                
                sheetPresentationController.prefersGrabberVisible = true
                
                sheetPresentationController.preferredCornerRadius = 40.0
                
                guard let songs = songs else { return }
                
                newListVC.song = songs[currentItemIndex]
                
                present(newListVC, animated: true)
            }
        }
        
    }
    
    private func configureButtonView() {
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .playing {
            
            playPauseImage.image = UIImage(named: "pause.fill")
            
        }
        else {
            
            playPauseImage.image = UIImage(named: "play.fill")
        }
    }
    
    private func configureView() {
        
        volumeSilder.value = PlaySongManager.sharedInstance.player.volume
        
        musicSlider.value = Float(Double(PlaySongManager.sharedInstance.currentTime) / Double( PlaySongManager.sharedInstance.position.duration))
        
        minTimeLabel.text = String(format: "%02d:%02d", Int(PlaySongManager.sharedInstance.currentTime) / 60, Int(PlaySongManager.sharedInstance.currentTime) % 60)
        
        maxTimeLabel.text = String(format: "%02d:%02d", Int( PlaySongManager.sharedInstance.position.duration) / 60, Int( PlaySongManager.sharedInstance.position.duration) % 60)
    }
    
    private func configureButton(currentItemIndex: Int) {
        
        guard KeychainManager.sharedInstance.id != nil else { return }

        guard let songs = songs, let songID = songs[currentItemIndex].id else { return }

        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.songs) { result in
            
            let id = result.id.filter { $0 == songID }

            if !id.isEmpty {
                
                DispatchQueue.main.async {
                    
                    self.favoriteView.image = UIImage(named: "heart.fill")
                    
                }
            }
            else {
        
                DispatchQueue.main.async {
                    
                    self.favoriteView.image = UIImage(named: "heart")
                    
                }
            }
            
            self.isFavorite.toggle()
            
            return
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
        
        guard let songs = songs, let songURL = songs[self.currentItemIndex].attributes?.previews?[0].url else { return }
    
        let activityVC = UIActivityViewController(activityItems: [songURL], applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    private func configureSong() {
        
        if let songs = songs {
            
            if let artworkURL = songs[self.currentItemIndex].attributes?.artwork?.url, let width = songs[self.currentItemIndex].attributes?.artwork?.width, let height = songs[self.currentItemIndex].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                self.songImage.loadImage(pictureURL)
                
            }
    
            DispatchQueue.main.async {
        
                self.songLabel.text = songs[self.currentItemIndex].attributes?.name
                
                self.singerLabel.text = songs[self.currentItemIndex].attributes?.artistName
    
            }
        }
    }
    
    @objc func previousButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }
        
        musicSlider.value = 0.0
        
        minTimeLabel.text = String(format: "%02d:%02d", 0, 0)

        PlaySongManager.sharedInstance.closePlayer()
        
        currentItemIndex = (currentItemIndex + songs.count - 1) % songs.count
        
        selectData(index: currentItemIndex, isFromMiniPlayer: false)
        
        configureSong()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
    }
    
    @objc func nextButton(_ sender: UIButton) {
        
        guard let songs = songs else { return }
        
        minTimeLabel.text = String(format: "%02d:%02d", 0, 0)
        
        musicSlider.value = 0.0

        PlaySongManager.sharedInstance.closePlayer()

        currentItemIndex = (currentItemIndex + songs.count + 1) % songs.count
        
        selectData(index: currentItemIndex, isFromMiniPlayer: false)
        
        configureSong()
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
        
    }
    
    @objc func playPauseButton(_ sender: UIButton) {
  
        guard let songs = songs, let url = songs[self.currentItemIndex].attributes?.previews?[0].url else { return }
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .paused {
            
            PlaySongManager.sharedInstance.playMusic(url: url)
            
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
    
        guard let songs = songs else { return }

        currentItemIndex = index
    
        singerLabel.text = songs[self.currentItemIndex].attributes?.artistName
        
        songLabel.text = songs[self.currentItemIndex].attributes?.name
        
        PlaySongManager.sharedInstance.current = currentItemIndex
        
        PlaySongManager.sharedInstance.maxCount = songs.count

        if let url = songs[self.currentItemIndex].attributes?.previews?[0].url, let songURL = URL(string: url) {
            
            if isFromMiniPlayer == true {
                
                configureSong()
                
            }
            else {

                PlaySongManager.sharedInstance.setupPlayer(with: songURL)
                
                configureSong()
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
