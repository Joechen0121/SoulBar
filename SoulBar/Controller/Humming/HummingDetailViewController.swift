//
//  HummingDetailViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/2.
//

import UIKit

class HummingDetailViewController: UIViewController {

    static let storyboardID = "HummingDetailVC"
    
    var hummingSongs = [Humming]()
    
    @IBOutlet weak var resultCount: UILabel!
    
    @IBOutlet weak var hummingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hummingTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            
            self.resultCount.text = "\(self.hummingSongs.count) songs"
        }
    }
}

extension HummingDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return hummingSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HummingTableViewCell.identifier, for: indexPath) as? HummingTableViewCell else {
            
            fatalError("Cannot create humming cells")
        }
        
        cell.songName.text = hummingSongs[indexPath.row].title
        
        var artists: String = ""
        
        hummingSongs[indexPath.row].artists?.forEach { artist in
            
            if let name = artist.name {
                
                artists += name
                
                artists += " "
            }
        }
        
        cell.artists.text = artists
        
        return cell
    }
}
