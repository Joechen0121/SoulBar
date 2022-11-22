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
        
        case recommend
    }
    
    @IBOutlet weak var homeTableView: UITableView!
    
    private let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.dataSource = self
        
        homeTableView.delegate = self
        
        homeTableView.rowHeight = UIScreen.main.bounds.height / 3.5
        
        homeTableView.separatorStyle = .none
        
        homeTableView.showsVerticalScrollIndicator = false
        
        homeTableView.showsHorizontalScrollIndicator = false
        
        homeTableView.register(UINib.init(nibName: AlbumsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumsTableViewCell.identifier)
        
        homeTableView.register(UINib.init(nibName: PlaylistsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PlaylistsTableViewCell.identifier)
        
        homeTableView.register(UINib.init(nibName: RecommendTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RecommendTableViewCell.identifier)
        
        //configureNavigationButton()
        
        setupUI()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)]

        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)

        showImage(false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)]
        
        self.navigationItem.largeTitleDisplayMode = .automatic
 
        showImage(true)
        
    }
    
    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.imageView.alpha = show ? 1.0 : 0.0
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

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
        
        return 4
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
            
        case .recommend:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecommendTableViewCell.identifier, for: indexPath) as? RecommendTableViewCell else {
                
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
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
                //self.navigationController?.pushViewController(playSongVC, animated: true)
            }
        }
    }
}

extension HomeViewController: RecommendDelegate {
    
    func didSelectRecommendItem(songs: SongsChartsInfo, indexPath: IndexPath) {
        
        if let playSongVC = self.storyboard?.instantiateViewController(withIdentifier: PlaySongViewController.storyboardID) as? PlaySongViewController {

            MusicManager.sharedInstance.fetchSong(with: songs.id) { result in
                
                playSongVC.songs = result
                
                playSongVC.modalPresentationStyle = .fullScreen
                
                self.present(playSongVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
            
        case 0:
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 15))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Hot Songs"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
        case 1:
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 15))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Hot Albums"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
        case 2:
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 15))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Hot Playlists"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
            
        case 3:
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 15))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Recommend For You"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
        default:

            return nil
 
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.main.bounds.height / 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 3 {

            return UIScreen.main.bounds.height / 2
        }
        else {

            return UIScreen.main.bounds.height / 3.5
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let height = navigationController?.navigationBar.frame.height else { return }
        
        moveAndResizeImage(for: height)
    }

}
