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
    
    @IBOutlet weak var newListTableView: UITableView!
    
    @IBOutlet weak var newListButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newListTableView.dataSource = self
        
        newListTableView.delegate = self
        
        configureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureListData()
    }

    func configureListData() {
        
        self.favoriteListsInfo = []
        
        FirebaseFavoriteManager.sharedInstance.fetchFavoriteListData { result in
            
            self.favoriteListsInfo = result

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
        
        cell.listName.text = favoriteListsInfo[indexPath.row].name
        
        return cell
        
    }
}

extension NewListDisplayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
    }
}
