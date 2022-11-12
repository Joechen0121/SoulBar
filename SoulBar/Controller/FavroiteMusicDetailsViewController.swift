//
//  FavroiteMusicDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/12.
//

import UIKit
import Kingfisher

class FavoriteMusicDetailsViewController: UIViewController {
    
    static let storyboardID = "FavoriteMusicDetailsVC"

    @IBOutlet weak var playPauseButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var musicDetailsTableView: UITableView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var songCount: UILabel!
    
    @IBOutlet weak var listTitle: UILabel!
    
    var favoriteSongs: [SongsSearchInfo]?
    
    @IBOutlet weak var playPauseView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        musicDetailsTableView.dataSource = self
        
        musicDetailsTableView.delegate = self
        
        musicDetailsTableView.register(UINib.init(nibName: FavoriteMusicDetailsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicDetailsTableViewCell.identifier)
        
        viewHeight.constant = UIScreen.main.bounds.height / 5
        
        playPauseButtonWidth.constant = viewHeight.constant / 3
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(playPauseButton))
        
        playPauseView.isUserInteractionEnabled = true
        
        playPauseView.addGestureRecognizer(playPauseTap)
        
        configureLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let count = favoriteSongs?.count else { return }
        
        songCount.text = " \(count) songs "
        
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.favoriteSongs = nil
    }
    
    func configureLabel() {
        
        songCount.layer.masksToBounds = true
        
        songCount.layer.borderColor = UIColor.black.cgColor
        
        songCount.layer.borderWidth = 1
        
        songCount.layer.cornerRadius = 10
    }
    
    @objc func playPauseButton() {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
            
            playSongVC.songs = favoriteSongs
            
            playSongVC.modalPresentationStyle = .fullScreen
            
            self.present(playSongVC, animated: true)
            
        }
    }

}

extension FavoriteMusicDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favoriteSongs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicDetailsTableViewCell.identifier, for: indexPath) as? FavoriteMusicDetailsTableViewCell else {
            
            fatalError("Cannot create cell")
        }
        
        guard let songs = favoriteSongs else { return UITableViewCell() }
        
        cell.songName.text = songs[indexPath.row].attributes?.name
        cell.artist.text = songs[indexPath.row].attributes?.artistName
        
        cell.songImage.kf.indicatorType = .activity
        
        if let artworkURL = songs[indexPath.row].attributes?.artwork?.url, let width = songs[indexPath.row].attributes?.artwork?.width, let height = songs[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            cell.songImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
}

extension FavoriteMusicDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let song = favoriteSongs?[indexPath.row] else { return }
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
            
            playSongVC.songs = [song]
            
            playSongVC.modalPresentationStyle = .fullScreen
            
            self.present(playSongVC, animated: true)
            
        }
    }
}
