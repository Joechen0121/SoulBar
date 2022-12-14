//
//  ProfileViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit
import SwiftJWT

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var prfileViewHeightConstraint: NSLayoutConstraint!
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureTableView()
    
        registerCell()
        
        configureConstraints()
        
        configureNavigationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if KeychainManager.sharedInstance.id == nil {
            
            if let authVC = storyboard?.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as? AppleAuthViewController {
                
                authVC.modalPresentationStyle = .overCurrentContext
                
                self.present(authVC, animated: false)
            }
        }
        
        if let name = KeychainManager.sharedInstance.name {
            
            DispatchQueue.main.async {
                
                self.profileName.text = name
            }
            
        }
        
        configureActivityView()
    }
    
    private func configureNavigationButton() {
        
        guard let image = UIImage(named: "robot")?.withRenderingMode(.alwaysOriginal) else { return }

        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goToAIConsole))
        
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func goToAIConsole() {
        
        if let aiVC = self.storyboard?.instantiateViewController(withIdentifier: OpenAIConsoleViewController.storyboardID) as? OpenAIConsoleViewController {
            
            aiVC.modalPresentationStyle = .overFullScreen
            
            present(aiVC, animated: true)
            //self.navigationController?.pushViewController(aiVC, animated: true)
        }
        
    }
    
    private func configureActivityView() {
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        activityIndicatorView.tintColor = .black
        
        activityIndicatorView.center = self.view.center
        
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.isHidden = true
    }
    
    private func configureTableView() {
        
        profileTableView.dataSource = self
        
        profileTableView.delegate = self
        
        profileTableView.showsVerticalScrollIndicator = false
        
        profileTableView.showsHorizontalScrollIndicator = false
    }
    
    private func registerCell() {
        
        profileTableView.register(UINib.init(nibName: ProfileTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProfileTableViewCell.identifier)
    }
    
    private func configureConstraints() {
        
        prfileViewHeightConstraint.constant = UIScreen.main.bounds.height / 8
        
        profileTableView.rowHeight = 50
        
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Attention", message: "SoulBar User Setting ", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default) { _ in
            
            self.confirmLogOut(logOut: true)
        })
        
        alert.addAction(UIAlertAction(title: "Delete Account", style: .default) { _ in
            
            self.confirmDelete(delete: true)
            
        })
    
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))

        self.present(alert, animated: true)
    }
    
    private func confirmLogOut(logOut: Bool) {
        
        switch logOut {
            
        case true:

            KeychainManager.sharedInstance.removeID()
                
            KeychainManager.sharedInstance.removeUsername()
            
            goToRootOfTab(index: 0)
            
        case false:
            
            print("Nothing Happened for now")
        }
    }
    
    private func confirmDelete(delete: Bool) {
        
        switch delete {
            
        case true:
            
            guard let refreshToken = KeychainManager.sharedInstance.refreshToken else { return }
            
            self.activityIndicatorView.startAnimating()
            
            self.activityIndicatorView.isHidden = false
            
            let header = Header(kid: AuthManager.sharedInstance.teamID)
            
            let claims = AuthClaims(iss: AuthManager.sharedInstance.appleID, iat: Date(), exp: Date(timeIntervalSinceNow: 3600), aud: AuthManager.sharedInstance.aud, sub: AuthManager.sharedInstance.clientID)
            
            var jwt = JWT(header: header, claims: claims)
            
            let jwtSigner = JWTSigner.es256(privateKey: Data(AuthManager.sharedInstance.p8.utf8))
            
            do {
                
                let signedJWT = try jwt.sign(using: jwtSigner)
                
                AuthManager.sharedInstance.revokeToken(
                    clientID: AuthManager.sharedInstance.clientID,
                    clientSecret: signedJWT,
                    refreshToken: refreshToken) {
                        
                        KeychainManager.sharedInstance.removeRefreshToken()
                        
                        guard let userID = KeychainManager.sharedInstance.id else { return }
                        
                        FirebaseUserManager.sharedInstance.removeUserData(id: userID)

                        KeychainManager.sharedInstance.removeID()
                            
                        KeychainManager.sharedInstance.removeUsername()
                        
                        self.goToRootOfTab(index: 0)
                        
                        self.activityIndicatorView.stopAnimating()
                        
                        self.activityIndicatorView.isHidden = true
                }
                
            } catch {
                
                print(error)
            }
            
        case false:
            print("Nothing Happened for now")
        }
    }
    
    private func goToRootOfTab(index: Int) {
        
        self.navigationController?.popToRootViewController(animated: true)
        
        if let tab = self.tabBarController {
            
            tab.selectedIndex = index
        }
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
            
            if let eventVC = self.storyboard?.instantiateViewController(withIdentifier: ProfileEventsViewController.storyboardID) as? ProfileEventsViewController {
                
                self.navigationController?.pushViewController(eventVC, animated: true)
            }
            
        case .LikedArtists:
            
            if let artistVC = self.storyboard?.instantiateViewController(withIdentifier: ProfileArtistsViewController.storyboardID) as? ProfileArtistsViewController {
        
                self.navigationController?.pushViewController(artistVC, animated: true)
            }
            
        case .RecogHistory:
            
            if let historyVC = self.storyboard?.instantiateViewController(withIdentifier: ProfileHistoryViewController.storyboardID) as? ProfileHistoryViewController {
                
                self.navigationController?.pushViewController(historyVC, animated: true)
            }
            
        case .Privacy:
            
            if let privacyVC = self.storyboard?.instantiateViewController(withIdentifier: PrivacyViewController.storyboardID) as? PrivacyViewController {
                
                self.present(privacyVC, animated: true)
            }
            
        default:
            
            print("Unknown type")
            
        }
    }
}
