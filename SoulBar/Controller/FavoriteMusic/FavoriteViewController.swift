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
    
    var favoriteAlbums: [[SongsSearchInfo]] = []
    
    var favoriteAlbumsInfo: [[SongsSearchInfo]] = []
    
    var favoritePlaylist: [[SongsSearchInfo]] = []
    
    var favoritePlaylistInfo: [[SongsSearchInfo]] = []
    
    var favoriteLists: [[SongsSearchInfo]] = []
    
    var favoriteListsInfo: [FirebaseFavoriteListData] = []
    
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
        
        favoriteAlbums = []
        
        favoritePlaylist = []
        
        favoriteLists = []
        
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
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)])
        
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

        setupFavoriteAlbums()
        setupFavoritePlaylists()
        setupFavoriteLists()
    }
    
    func setupFavoriteAlbums() {
        
        self.favoriteAlbums = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteMusicData(with: K.FStore.Favorite.albums) { result in
            
            result.id.forEach { id in
                
                MusicManager.sharedInstance.fetchAlbumsCharts(with: id) { tracks in
                    
                    self.favoriteAlbumsInfo.append(tracks)
                    print(self.favoriteAlbumsInfo)
                    DispatchQueue.main.async {

                        self.favoriteListTableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func setupFavoritePlaylists() {
        
        self.favoritePlaylist = []
        
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
        
        
        switch section {
        
        case 0:
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Songs"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .clear
            
            headerView.addSubview(label)
            
            return headerView
            
        case 1:
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Albums"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .clear
            
            headerView.addSubview(label)
            
            return headerView
            
        case 2:
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Playlists"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .clear
            
            headerView.addSubview(label)
            
            return headerView
            
        case 3:
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height / 10))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: -headerView.frame.midY / 2, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Favorite Lists"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            headerView.backgroundColor = .clear
            
            headerView.addSubview(label)
            
            return headerView
            
        default:
            
            return UIView()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            
            return false
        }
        else {
            
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            switch indexPath.section {
                
            case 1:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.albums, id: favoriteAlbumsInfo[indexPath.row][0].id!)
                
                self.favoriteAlbums.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            case 2:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteMusicData(with: K.FStore.Favorite.playlists, id: favoritePlaylistInfo[indexPath.row][0].id!)
                
                self.favoritePlaylist.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            case 3:
                
                FirebaseFavoriteManager.sharedInstance.removeFavoriteListData(with: favoriteListsInfo[indexPath.row].name)
                
                self.favoriteListsInfo.remove(at: indexPath.row)
                
                tableView.reloadData()
                
            default:
                
                print("Unknown state for deleting ")
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "Favorite songs"
        }
        else if section == 1 {
            
            return "Favorite Albums"
        }
        else if section == 2 {
            
            return "Favorite Playlists"
        }
        else if section == 3 {
            
            return "Favorite Lists"
        }
        else {
            
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
            
        }
        else if section == 1 {

            return self.favoriteAlbumsInfo.count
        }
        else if section == 2 {
            
            return self.favoritePlaylistInfo.count
        }
        else if section == 3 {
            
            return self.favoriteListsInfo.count
        }
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteMusicTableViewCell.identifier, for: indexPath) as? FavoriteMusicTableViewCell else {
                
                fatalError("Cannot create music cell")
            }
            
            cell.musicName.text = "Love Songs"
            
            cell.musicImage.image = UIImage(named: "loveLogo")
            
            return cell
        }
        else if indexPath.section == 1 {
            
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
        else if indexPath.section == 2 {
            
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
        else if indexPath.section == 3 {
            
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
        
        if indexPath.section == 0 {
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = 0
        
                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
        }
        else if indexPath.section == 1 {
            
            guard !self.favoriteAlbumsInfo.isEmpty else {
                
                return
            }
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = 1
                
                musicDetails.favoriteSongsInfo = favoriteAlbumsInfo[indexPath.row]

                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
            
        }
        
        else if indexPath.section == 2 {
            
            guard !self.favoritePlaylistInfo.isEmpty else {
                
                return
            }
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = 2
                
                musicDetails.favoriteSongsInfo = favoritePlaylistInfo[indexPath.row]
                
                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
            
        }
        else {
            
//            guard !self.favoriteListsInfo.isEmpty else {
//
//                return
//            }

            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = 3
                
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
