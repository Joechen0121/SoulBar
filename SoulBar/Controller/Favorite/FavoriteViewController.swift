//
//  FavoriteViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import CoreMedia
import SwiftUI

class FavoriteViewController: UIViewController {

    @IBOutlet weak var favoriteListTableView: UITableView!
    
    var favoriteSongs: [[SongsSearchInfo]] = []
    
    var favoriteAlbumsInfo: [[SongsSearchInfo]] = []
    
    var favoritePlaylistInfo: [[SongsSearchInfo]] = []
    
    var favoriteListsInfo: [FirebaseFavoriteListData] = []
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    private let imageView = UIImageView(image: UIImage(systemName: "plus"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteListTableView.dataSource = self
        
        favoriteListTableView.delegate = self
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteMusicTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteMusicTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteAlbumsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteAlbumsTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoritePlaylistsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoritePlaylistsTableViewCell.identifier)
        
        favoriteListTableView.register(UINib.init(nibName: FavoriteListsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FavoriteListsTableViewCell.identifier)
        
        favoriteListTableView.separatorStyle = .none
        
        setupUI()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        favoriteSongs = []
        
        favoriteListsInfo = []
        
        favoritePlaylistInfo = []
        
        favoriteAlbumsInfo = []
    
        showImage(false)
    }
    
    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
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
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addListButton))
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showImage(true)
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        activityIndicatorView.isHidden = false
        
        loadWithGroup()

    }
    
    func loadWithGroup() {
        
        let group = DispatchGroup()
        
        let queue = DispatchQueue.global()
        
        queue.async(group: group) {
            
            FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in

                result.id.forEach { id in
                    
                    group.enter()
                    
                    MusicManager.sharedInstance.fetchAlbumsCharts(with: id) { tracks in
                        
                        self.favoriteAlbumsInfo.append(tracks)
                        
                        group.leave()
                    }
                }
                
                FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.playlists) { result in
                    
                    result.id.forEach { id in
                        
                        group.enter()
                        
                        MusicManager.sharedInstance.fetchPlaylistsCharts(with: id) { playlist in
                            
                            self.favoritePlaylistInfo.append(playlist)
                            
                            group.leave()
                        }
                    }
                    
                    FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in
                        
                        self.favoriteListsInfo = result
                        
                        group.notify(queue: .main) {
                            
                            print("Complete")
                            
                            DispatchQueue.main.async {
                                
                                self.favoriteListTableView.reloadData()
                                
                                self.activityIndicatorView.stopAnimating()
                                
                                self.activityIndicatorView.isHidden = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupFavoriteAlbums() {
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in

            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchAlbumsCharts(with: id) { tracks in
                    
                    self.favoriteAlbumsInfo.append(tracks)

                    DispatchQueue.main.async {

                        self.favoriteListTableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func setupFavoritePlaylists() {
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.playlists) { result in
            
            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchPlaylistsCharts(with: id) { playlist in
                    
                    self.favoritePlaylistInfo.append(playlist)
                    
                    DispatchQueue.main.async {

                        self.favoriteListTableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func setupFavoriteLists() {
        
        self.favoriteListsInfo = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in
            
            self.favoriteListsInfo = result
            
            DispatchQueue.main.async {

                self.favoriteListTableView.reloadData()
            }
        }
    }
    
    func configureNavigationButton() {
        
        let addListButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addListButton))
                        
        self.navigationItem.rightBarButtonItem = addListButton
    
    }
    
    @objc func addListButton() {
    
        if let newListPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: NewListPopUpViewController.storyboardID) as? NewListPopUpViewController {
        
            newListPopUpVC.modalPresentationStyle = .currentContext
            
            newListPopUpVC.modalTransitionStyle = .crossDissolve
            
            self.present(newListPopUpVC, animated: true)
        }
        
    }
}

extension FavoriteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch FavoriteType(rawValue: section) {
        
        case .FavSongs:
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Songs"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
            
        case .FavAlbums:
            
            // guard !self.favoriteAlbumsInfo.isEmpty else { return nil }
        
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Albums"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
            
        case .FavPlaylists:
            
            // guard !self.favoritePlaylistInfo.isEmpty else { return nil }
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Playlists"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
            
        case .FavLists:
            
            // guard !self.favoriteListsInfo.isEmpty else { return nil }
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Lists"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .systemBackground
            
            headerView.addSubview(label)
            
            return headerView
            
        default:
            
            return nil
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == FavoriteType.FavSongs.rawValue {
            
            return false
        }
        else {
            
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            switch FavoriteType(rawValue: indexPath.section) {
                
            case .FavAlbums:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: favoriteAlbumsInfo[indexPath.row][0].id!)
                
                self.favoriteAlbumsInfo.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            case .FavPlaylists:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.playlists, id: favoritePlaylistInfo[indexPath.row][0].id!)
                
                self.favoritePlaylistInfo.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            case .FavLists:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteListData(with: favoriteListsInfo[indexPath.row].name)
                
                self.favoriteListsInfo.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            default:
                
                print("Unknown state for deleting ")
                
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
    
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch FavoriteType(rawValue: section) {
            
        case .FavSongs:
            
            return 1
            
        case .FavAlbums:
            
            return self.favoriteAlbumsInfo.count
            
        case .FavPlaylists:
            
            return self.favoritePlaylistInfo.count
            
        case .FavLists:
            
            return self.favoriteListsInfo.count
            
        default:
            
            return 1
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = FavoriteType(rawValue: indexPath.section)
        
        if section == .FavSongs {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicTableViewCell.identifier, for: indexPath) as? FavoriteMusicTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            cell.musicName.text = "Liked Songs"
            
            cell.musicImage.image = UIImage(named: "loveLogo")
            
            return cell
        }
        else if section == .FavAlbums {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteAlbumsTableViewCell.identifier, for: indexPath) as? FavoriteAlbumsTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            guard !favoriteAlbumsInfo.isEmpty else { return UITableViewCell() }

            cell.musicName.text = favoriteAlbumsInfo[indexPath.row][0].attributes?.name
            
            cell.musicImage.kf.indicatorType = .activity
            
            if let artworkURL = favoriteAlbumsInfo[indexPath.row][0].attributes?.artwork?.url, let width = favoriteAlbumsInfo[indexPath.row][0].attributes?.artwork?.width, let height = favoriteAlbumsInfo[indexPath.row][0].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.musicImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
        }
        else if section == .FavPlaylists {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritePlaylistsTableViewCell.identifier, for: indexPath) as? FavoritePlaylistsTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            guard !favoritePlaylistInfo.isEmpty else { return UITableViewCell() }
            
            cell.musicName.text = favoritePlaylistInfo[indexPath.row][0].attributes?.name
            
            cell.musicImage.kf.indicatorType = .activity
            
            if let artworkURL = favoritePlaylistInfo[indexPath.row][0].attributes?.artwork?.url, let width = favoritePlaylistInfo[indexPath.row][0].attributes?.artwork?.width, let height = favoritePlaylistInfo[indexPath.row][0].attributes?.artwork?.height {
                
                let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
                
                cell.musicImage.kf.setImage(with: URL(string: pictureURL))
            }
            
            return cell
        }
        else if section == .FavLists {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteListsTableViewCell.identifier, for: indexPath) as? FavoriteListsTableViewCell else {

                fatalError("Cannot create music cell")
            }

            guard !favoriteListsInfo.isEmpty else { return UITableViewCell() }

            cell.listName.text = favoriteListsInfo[indexPath.row].name
            
            return cell
        }
        else {
            
            return UITableViewCell()
        }
    }
}

extension FavoriteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = FavoriteType(rawValue: indexPath.section)
        
        if section == .FavSongs {
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = .FavSongs
        
                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
        }
        else if section == .FavAlbums {
            
            guard !self.favoriteAlbumsInfo.isEmpty else {
                
                return
            }
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = .FavAlbums
                
                musicDetails.favoriteSongsInfo = favoriteAlbumsInfo[indexPath.row]

                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
            
        }
        
        else if section == .FavPlaylists {
            
            guard !self.favoritePlaylistInfo.isEmpty else {
                
                return
            }
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = .FavPlaylists
                
                musicDetails.favoriteSongsInfo = favoritePlaylistInfo[indexPath.row]
                
                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
            
        }
        else {

            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = .FavLists
                
                musicDetails.favoriteListsName = favoriteListsInfo[indexPath.row].name
    
                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
            
        }
    }
    
    
}

extension FavoriteViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let height = navigationController?.navigationBar.frame.height else { return }
        
        moveAndResizeImage(for: height)
    }

}
