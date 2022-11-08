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
}

extension RootTabBarViewController: MiniPlayerDelegate {
    
    func presentPlaySongView() {
        print("======delegate present")

        if PlaySongManager.sharedInstance.player.status == AVPlayer.Status.readyToPlay {
            
            if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {

                guard let url = PlaySongManager.sharedInstance.currentSong?.attributes?.previews?[0].url else { return }
                
                var song: [SongsSearchInfo] = []
                
                song.append(PlaySongManager.sharedInstance.currentSong!)
                
                playSongVC.songs = song

                self.present(playSongVC, animated: true)
            }
        }
    }
}
