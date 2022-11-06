//
//  ProfileViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.dataSource = self
    
        profileTableView.register(UINib.init(nibName: ProfileTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        profileTableView.rowHeight = 50
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
        
        cell.profileImage.image = UIImage(systemName: ProfileData.data[indexPath.row].profileImage)
        cell.profileName.text = ProfileData.data[indexPath.row].profileName
        
        return cell
    }
}
