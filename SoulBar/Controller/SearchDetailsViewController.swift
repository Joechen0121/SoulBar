//
//  SearchDetailsViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import UIKit

class SearchDetailsViewController: UIViewController {

    @IBOutlet weak var searchDetailsTableView: UITableView!
    
    static let storyboardID = "SearchDetailsVC"
    
    let musicManager = MusicManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchDetailsTableView.dataSource = self
    }
    
    
}

extension SearchDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    
    
    
    
    
}
