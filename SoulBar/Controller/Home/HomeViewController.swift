//
//  HomeViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit

class HomeViewController: UIViewController {

    enum HomeSongType: Int, CaseIterable {
        
        case newSongs = 0
        
        case hotAlbums
        
        case hotPlaylist
    }
    
    @IBOutlet weak var homeTableView: UITableView!
    
    private let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.dataSource = self
        
        homeTableView.delegate = self
        
        homeTableView.rowHeight = UITableView.automaticDimension
        homeTableView.rowHeight = 250
        
        homeTableView.separatorStyle = .none
        
        homeTableView.register(UINib.init(nibName: AlbumsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumsTableViewCell.identifier)
        
        homeTableView.register(UINib.init(nibName: PlaylistsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PlaylistsTableViewCell.identifier)
        
        //configureNavigationButton()
        
        setupUI()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showImage(false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showImage(true)
    }
    
    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.imageView.alpha = show ? 1.0 : 0.0
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

        title = "SoulBar"

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = K.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -K.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -K.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: K.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchButton))
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - K.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (K.NavBarHeightLargeState - K.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = K.ImageSizeForSmallState / K.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = K.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
 
            let maxYTranslation = K.ImageBottomMarginForLargeState - K.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (K.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    func configureNavigationButton() {
        
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchButton))
                        
        self.navigationItem.rightBarButtonItem = searchButton
    
    }

    @objc func searchButton() {
        
        if let searchVC = self.storyboard?.instantiateViewController(withIdentifier: SearchDetailsViewController.storyboardID) as? SearchDetailsViewController {
            
            self.navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let state = HomeSongType(rawValue: indexPath.section)
        switch state {
            
        case .newSongs:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableViewCell.identifier, for: indexPath) as? SongsTableViewCell else {
                fatalError("Cannot create table view cell")
            }
            
            cell.delegate = self
            
            return cell
            
        case .hotAlbums:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsTableViewCell.identifier, for: indexPath) as? AlbumsTableViewCell else {

                fatalError("Cannot create table view cell")

            }
            
            cell.delegate = self
            
            return cell
            
        case .hotPlaylist:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistsTableViewCell.identifier, for: indexPath) as? PlaylistsTableViewCell else {

                fatalError("Cannot create table view cell")

            }
            cell.delegate = self
            
            return cell
            
        default:
            fatalError("Unknown section state")
        }
    }
}

extension HomeViewController: PlaylistsDelegate {
    
    func didSelectPlaylistsItem(playlists: PlaylistsChartsInfo, indexPath: IndexPath) {
        if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {
            
            songlistVC.state = 0
            
            songlistVC.playlist = playlists
            
            self.navigationController?.pushViewController(songlistVC, animated: true)
        }
    }
}

extension HomeViewController: SongsDelegate {
    
    func didSelectSongsItem(songs: SongsChartsInfo, indexPath: IndexPath) {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {

            
            MusicManager.sharedInstance.fetchSong(with: songs.id) { result in
                
                playSongVC.songs = result
                
                
                self.present(playSongVC, animated: true)
                //self.navigationController?.pushViewController(playSongVC, animated: true)
            }
           
        }
        
    }
    
    
}


extension HomeViewController: AlbumsDelegate {
    
    func didSelectAlbumsItem(albums: AlbumsChartsInfo, indexPath: IndexPath) {
        if let songlistVC = self.storyboard?.instantiateViewController(withIdentifier: SongListViewController.storyboardID) as? SongListViewController {
            songlistVC.state = 1
            songlistVC.album = albums
            self.navigationController?.pushViewController(songlistVC, animated: true)
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            
            return "Hot Songs"
        }
        else if section == 1 {
            
            return "Hot Albums"
        }
        else if section == 2 {
            
            return "Hot Playlists"
        }
        else {
            
            return ""
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let height = navigationController?.navigationBar.frame.height else { return }
        
        moveAndResizeImage(for: height)
    }

}
