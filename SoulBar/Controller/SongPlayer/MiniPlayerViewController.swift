//
//  MiniPlayerViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/8.
//

import UIKit
import AVFoundation

protocol MiniPlayerDelegate {
    
    func presentPlaySongView()
}

class MiniPlayerViewController: UIViewController {
    
    var delegate: MiniPlayerDelegate?
    
    var songName = UILabel()
    
    var songImage = UIImageView()
    
    var playPauseButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(image: UIImage(named: "redBG"))
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        backgroundEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let container = UIView()
        container.frame = view.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundImageView.frame = container.bounds
        backgroundEffectView.frame = container.bounds
        
        container.addSubview(backgroundImageView)
        
        view.insertSubview(container, at: 0)
        
        songImage.image = UIImage(systemName: "music")
        
        songImage.contentMode = .scaleAspectFill
        
        songImage.backgroundColor = .black
        
        self.view.addSubview(songImage)
        
        songImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            songImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            songImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            songImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            songImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            songImage.widthAnchor.constraint(equalToConstant: 48.0)
        ])
        
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        playPauseButton.imageView?.tintColor = K.Colors.customRed
        
        playPauseButton.tintColor = .black
        
        self.view.addSubview(playPauseButton)
        
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        songName.textAlignment = .left
        
        songName.text = "Song Name"
        
        songName.font = UIFont(name: "Kohinoor Bangla Semibold", size: 15.0)
        
        self.view.addSubview(songName)
        
        songName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playPauseButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            playPauseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            playPauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([
            songName.leadingAnchor.constraint(equalTo: self.songImage.trailingAnchor, constant: 20),
            songName.trailingAnchor.constraint(equalTo: self.playPauseButton.leadingAnchor, constant: 5),
            songName.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            songName.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        self.playPauseButton.addTarget(self, action: #selector(playPauseMusic), for: .touchUpInside)
        
        let leftside = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        leftside.direction = .left
        view.addGestureRecognizer(leftside)
        
        let rightside = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        rightside.direction = .right
        view.addGestureRecognizer(rightside)
    }
    
    @objc func swiped(gesture: UISwipeGestureRecognizer) {
        
        switch gesture.direction {
            
        case UISwipeGestureRecognizer.Direction.left:
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    
                    self.view.frame.origin.x -= 100.0
                    
                    self.view.alpha = 0 },
                
                completion: { _ in
                    
                    PlaySongManager.sharedInstance.closePlayer()
                    
                    PlaySongManager.sharedInstance.currentSong = nil
                    
                    self.view.frame.origin.x += 100.0
                    
                    self.view.isHidden = true
                    
                    self.view.alpha = 1
                    
                })
            
        case UISwipeGestureRecognizer.Direction.right:
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    
                    self.view.frame.origin.x += 100.0
                    
                    self.view.alpha = 0 },
                
                completion: { _ in
                    
                    PlaySongManager.sharedInstance.closePlayer()
                    
                    PlaySongManager.sharedInstance.currentSong = nil
                    
                    self.view.frame.origin.x -= 100.0
                    
                    self.view.isHidden = true
                    
                    self.view.alpha = 1
                    
                })
            
        case UISwipeGestureRecognizer.Direction.up:
            print("up")
            
        case UISwipeGestureRecognizer.Direction.down:
            print("down")
            
        default:
            print("ERROR")
            
        }
        
    }
    
    @objc func playPauseMusic() {
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .playing {
            
            PlaySongManager.sharedInstance.pauseMusic()
            
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
            playPauseButton.imageView?.tintColor = K.Colors.customRed
        }
        else {
            
            guard let songs = PlaySongManager.sharedInstance.songs, !songs.isEmpty else { return }
            
            guard let song = PlaySongManager.sharedInstance.songs?[PlaySongManager.sharedInstance.current], let url = song.attributes?.previews?[0].url else {
                
                return
            }
            
            PlaySongManager.sharedInstance.playMusic(url: url)
            
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playPauseButton.imageView?.tintColor = K.Colors.customRed
        }
    }
    
    @objc func tapDetected() {
        
        delegate?.presentPlaySongView()
    }
}
