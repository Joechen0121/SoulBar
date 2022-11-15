//
//  NewListDisplayViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/7.
//

import UIKit

class NewListDisplayViewController: UIViewController {

    static let storyboardID = "NewListDisplayVC"
    
    var favoriteListsInfo: [FirebaseFavoriteListData] = []
    
    var isFavoriteInLists: [Bool] = []
    
    var song: SongsSearchInfo?
    
    @IBOutlet weak var newListTableView: UITableView!
    
    @IBOutlet weak var newListButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newListTableView.dataSource = self
        
        newListTableView.delegate = self
        
        let backgroundImageView = UIImageView(image: UIImage(named: "redBG"))
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
    
        configureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureListData()
    }

    func configureListData() {
        
        if KeychainManager.sharedInstance.id == nil {
            let authVC = storyboard!.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as! AppleAuthViewController
            authVC.modalPresentationStyle = .overCurrentContext
            self.present(authVC, animated: false)
            
            return
        }
        
        self.favoriteListsInfo = []
        
        self.isFavoriteInLists = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in
            
            self.favoriteListsInfo = result
            
            for listIndex in 0..<result.count {
                
                guard let song = self.song else {
                    return
                }
                
                if !result[listIndex].songs.filter({ $0 == song.id }).isEmpty {
                    
                    self.isFavoriteInLists.append(true)
                }
                else {
                    
                    self.isFavoriteInLists.append(false)
                }
                
            }
    
            DispatchQueue.main.async {
                
                self.newListTableView.reloadData()
            }
        }
    }
    
    @IBAction func createNewListButton(_ sender: UIButton) {
        
        if let newListPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: NewListPopUpViewController.storyboardID) as? NewListPopUpViewController {
            
            newListPopUpVC.modalPresentationStyle = .overCurrentContext
            
            newListPopUpVC.modalTransitionStyle = .crossDissolve
            
            present(newListPopUpVC, animated: true)
        }
    }
    
    func configureButton() {
        
        newListButton.layer.cornerRadius = newListButton.frame.height / 2
        
        newListButton.backgroundColor = UIColor.lightGray
    }
}

extension NewListDisplayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favoriteListsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewListTableViewCell.identifier, for: indexPath) as? NewListTableViewCell else {
            
            fatalError("Cannot create new list table cell")
        }
        
        guard !favoriteListsInfo.isEmpty else { return UITableViewCell() }
        
        cell.listName.text = favoriteListsInfo[indexPath.row].name

        if isFavoriteInLists[indexPath.row] == true {
            
            cell.listStatusImage.image = UIImage(systemName: "checkmark.circle.fill")
        }
        else {
            cell.listStatusImage.image = nil
        }
        
        return cell
        
    }
}

extension NewListDisplayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let songID = song?.id else { return }

        if isFavoriteInLists[indexPath.row] == true {
            
            FirebaseFavoriteManager.sharedInstance.removeFavoriteSongListData(with: favoriteListsInfo[indexPath.row].name, songID: songID) {
    
                self.isFavoriteInLists[indexPath.row] = false
                
                tableView.reloadData()
            }
            
        }
        else {

            FirebaseFavoriteManager.sharedInstance.addFavoriteListData(with: favoriteListsInfo[indexPath.row].name, id: songID) {
                
                self.isFavoriteInLists[indexPath.row] = true
                
                tableView.reloadData()
            }
        }
    }
}
