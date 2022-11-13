//
//  ProfileViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit

class ProfileViewController: UIViewController {
    
    enum ProfileType: Int {
        
        case LikedSongs = 0
        
        case MyEvent
        
        case LikedArtists
        
        case RecogHistory
        
        case Blacklists
        
    }

    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var prfileViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logoutViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.dataSource = self
        
        profileTableView.delegate = self
    
        profileTableView.register(UINib.init(nibName: ProfileTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        prfileViewHeightConstraint.constant = UIScreen.main.bounds.height / 7
        
        profileTableView.rowHeight = UIScreen.main.bounds.height / 10
        
        logoutViewHeightConstraint.constant = UIScreen.main.bounds.height / 15
        
        logoutButton.layer.masksToBounds = true
        
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
        
        logoutButton.backgroundColor = K.Colors.customRed
    }

}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ProfileData.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
            
            fatalError("Cannot create profile cell")
        }
        
        cell.profileImage.image = UIImage(named: ProfileData.data[indexPath.row].profileImage)
        cell.profileName.text = ProfileData.data[indexPath.row].profileName
        
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch ProfileType(rawValue: indexPath.row) {
            
        case .LikedSongs:
            
            if let musicDetails = self.storyboard?.instantiateViewController(withIdentifier: FavoriteMusicDetailsViewController.storyboardID) as? FavoriteMusicDetailsViewController {
                
                musicDetails.state = .FavSongs
        
                self.navigationController?.pushViewController(musicDetails, animated: true)
            }
            
        case .MyEvent:
            
            print("myevent")
            
        case .LikedArtists:
            
            print("liked artist")
            if let artistVC = self.storyboard?.instantiateViewController(withIdentifier: ProfileArtistsViewController.storyboardID) as? ProfileArtistsViewController {
        
                self.navigationController?.pushViewController(artistVC, animated: true)
            }
            
        case .RecogHistory:
            
            print("recog")
            
            if let historyVC = self.storyboard?.instantiateViewController(withIdentifier: ProfileHistoryViewController.storyboardID) as? ProfileHistoryViewController {
                
                self.navigationController?.pushViewController(historyVC, animated: true)
            }
            
        case .Blacklists:
            
            print("blacklist")
            
        default:
            
            print("Unknown type")
            
        }
    }
}
