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
    
    let musicManager = MusicManager()
    
    @IBOutlet weak var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.dataSource = self
        
        homeTableView.rowHeight = UITableView.automaticDimension
        homeTableView.rowHeight = 250
        
        homeTableView.separatorStyle = .none
        
        homeTableView.register(UINib.init(nibName: AlbumsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AlbumsTableViewCell.identifier)
        
        configureNavigationButton()
        
    }
    
    func configureNavigationButton() {
        
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchButton))
                        
        self.navigationItem.rightBarButtonItem = searchButton
    
    }

    @objc func searchButton() {
        
        if let searchVC = self.storyboard!.instantiateViewController(withIdentifier: SearchDetailsViewController.storyboardID) as? SearchDetailsViewController {
            
            self.navigationController!.pushViewController(searchVC, animated: true)
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
            
            return cell
        
        case .hotAlbums:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsTableViewCell.identifier, for: indexPath) as? AlbumsTableViewCell else {

                fatalError("Cannot create table view cell")

            }
            
            return cell
            
        case .hotPlaylist:
            
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
//
//                fatalError("Cannot create table view cell")
//
//            }
            
            return UITableViewCell()
            
        default:
            fatalError("Unknown section state")
        }
        
        

    }
    
    
    
    
}
