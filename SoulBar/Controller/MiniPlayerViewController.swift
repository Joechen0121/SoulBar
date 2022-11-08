//
//  MiniPlayerViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/8.
//

import UIKit

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

        //self.view.backgroundColor = .white
        let backgroundImageView = UIImageView(image: UIImage(named: "demoAlbum"))
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        backgroundEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let container = UIView()
        container.frame = view.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundImageView.frame = container.bounds
        backgroundEffectView.frame = container.bounds
        
        container.addSubview(backgroundImageView)
        container.addSubview(backgroundEffectView)
        
        view.insertSubview(container, at: 0)

        songImage.image = UIImage(systemName: "music")
        
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
        
        songName.textAlignment = .left

        songName.text = "Song Name"

        self.view.addSubview(songName)

        songName.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            songName.leadingAnchor.constraint(equalTo: self.songImage.trailingAnchor, constant: 20),
            songName.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            songName.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            songName.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])

        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        self.view.addSubview(playPauseButton)

        playPauseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playPauseButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            playPauseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            playPauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }

    @objc func tapDetected() {
        
        delegate?.presentPlaySongView()
    }
}
