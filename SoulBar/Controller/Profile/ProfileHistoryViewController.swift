//
//  ProfileHistoryViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/13.
//

import UIKit
import CoreMedia
import Kingfisher

class ProfileHistoryViewController: UIViewController {
    
    static let storyboardID = "ProfileHistoryVC"
    
    @IBOutlet weak var songCount: UILabel!
    
    @IBOutlet weak var playImage: UIImageView!
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playButtonWidth: NSLayoutConstraint!
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var history: [FirebaseHistoryPlayData] = []
    
    var songsTracks: [SongsSearchInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.dataSource = self
        
        historyTableView.delegate = self
        
        historyTableView.showsVerticalScrollIndicator = false
        
        historyTableView.showsHorizontalScrollIndicator = false
        
        historyTableView.register(UINib.init(nibName: ProfileHistoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProfileHistoryTableViewCell.identifier)
        
        viewHeightConstraint.constant = UIScreen.main.bounds.height / 5
        
        let playTap = UITapGestureRecognizer(target: self, action: #selector(play))
        
        playImage.isUserInteractionEnabled = true
        
        playImage.addGestureRecognizer(playTap)
        
        playButtonWidth.constant = viewHeightConstraint.constant / 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        activityIndicatorView.isHidden = false
        
        loadDataWithGroup()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        history = []
        
        songsTracks = []
        
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func loadDataWithGroup() {
        
        let group = DispatchGroup()
        
        let queue = DispatchQueue.global()
        
        queue.async(group: group) {
            
            FirebaseHistoryManager.sharedInstance.fetchHistoryPlayData { result in
                
                self.history = result
                
                self.history.sort(by: {$0.list.time > $1.list.time})
                
                let semaphore = DispatchSemaphore(value: 1)
                
                let queue = DispatchQueue.global()
                
                self.history.forEach { lists in
                    
                    group.enter()
                    
                    queue.async {
                        
                        semaphore.wait()
                        
                        MusicManager.sharedInstance.fetchSong(with: lists.list.songID) { result in
                            
                            self.songsTracks.append(result[0])
                            
                            semaphore.signal()
                            
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    
                    print("Complete")
                    
                    DispatchQueue.main.async {
                        
                        self.songCount.text = "\(self.songsTracks.count) songs"
                        
                        self.historyTableView.reloadData()
                        
                        self.activityIndicatorView.stopAnimating()
                        
                        self.activityIndicatorView.isHidden = true
                    }
                }
            }
        }
    }
    
    
    @objc func play() {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
            
            playSongVC.songs = songsTracks
            
            playSongVC.modalPresentationStyle = .fullScreen
            
            self.present(playSongVC, animated: true)
        }
    }
    
}

extension ProfileHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songsTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileHistoryTableViewCell.identifier, for: indexPath) as? ProfileHistoryTableViewCell else {
            
            fatalError("Cannot create history cell")
        }
        
        guard !songsTracks.isEmpty else { return UITableViewCell() }
        
        guard !history.isEmpty else { return UITableViewCell() }
        
        cell.songName.text = songsTracks[indexPath.row].attributes?.name
        cell.artist.text = songsTracks[indexPath.row].attributes?.artistName
        cell.time.text = DateFormatter.posixFormatter.timeIntervalToString(timeinterval: history[indexPath.row].list.time)
        
        cell.songImage.kf.indicatorType = .activity
        
        if let artworkURL = songsTracks[indexPath.row].attributes?.artwork?.url, let width = songsTracks[indexPath.row].attributes?.artwork?.width, let height = songsTracks[indexPath.row].attributes?.artwork?.height {
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            cell.songImage.kf.setImage(with: URL(string: pictureURL))
            
        }
        
        return cell
    }
    
}

extension ProfileHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {
            
            playSongVC.songs = [songsTracks[indexPath.row]]
            
            playSongVC.modalPresentationStyle = .fullScreen
            
            self.present(playSongVC, animated: true)
            
        }
        
    }
    
}
