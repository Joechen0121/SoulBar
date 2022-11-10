//
//  RootTabBarViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/8.
//

import UIKit
import AVFoundation

class RootTabBarViewController: UITabBarController {
    
    var miniPlayer: MiniPlayerViewController = {
        let vc = MiniPlayerViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    var containerView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        miniPlayer.delegate = self
        
        addChildView()

        setConstraints()
        print("Tab bar controller")
        
        if PlaySongManager.sharedInstance.player.status == AVPlayer.Status.readyToPlay {
            
            miniPlayer.view.isHidden = false
        }
        else {
            
            miniPlayer.view.isHidden = true
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMiniPlayerView),
            name: Notification.Name(rawValue: "didUpdateMiniPlayerView"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMiniPlayerButton),
            name: Notification.Name(rawValue: "didUpdateMiniPlayerButton"),
            object: nil
        )
    }
    
    @objc func updateMiniPlayerView() {
        
        miniPlayer.view.isHidden = false
        
        updateMiniPlayerUI()
    }
    
    @objc func updateMiniPlayerButton() {
        
        if PlaySongManager.sharedInstance.player.timeControlStatus == .paused {
            
            miniPlayer.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
        }
        else {
            
            miniPlayer.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        }
    }
    
    func updateMiniPlayerUI() {
        
        guard let songs = PlaySongManager.sharedInstance.songs, songs.count > PlaySongManager.sharedInstance.current else { return }
        
        guard let song = PlaySongManager.sharedInstance.songs?[PlaySongManager.sharedInstance.current] else { return }
    
        miniPlayer.songName.text = song.attributes?.name
        
        if let artworkURL = song.attributes?.artwork?.url, let width = song.attributes?.artwork?.width, let height = song.attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            miniPlayer.songImage.kf.setImage(with: URL(string: pictureURL))
        }
        
    }

    func addChildView() {
        view.addSubview(containerView)
        addChild(miniPlayer)
        containerView.addSubview(miniPlayer.view)
        miniPlayer.didMove(toParent: self)
    }
    
    func setConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 64.0),
            
            miniPlayer.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            miniPlayer.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            miniPlayer.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            miniPlayer.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
}

extension RootTabBarViewController: MiniPlayerDelegate {
    
    func presentPlaySongView() {

        if PlaySongManager.sharedInstance.player.status == AVPlayer.Status.readyToPlay {
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {

                playSongVC.songs = PlaySongManager.sharedInstance.songs
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
            }
        }
    }
}
