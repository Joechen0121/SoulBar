//
//  FavoriteMusicDetailsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/12.
//

import UIKit

protocol FavoriteMusicDetailsTableViewDelegate {

    func removeTableViewCell(at indexPath: IndexPath)
    
}

class FavoriteMusicDetailsTableViewCell: UITableViewCell {

    static let identifier = String(describing: FavoriteMusicDetailsTableViewCell.self)
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var songImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var delegate: FavoriteMusicDetailsTableViewDelegate?
    
    var indexPath: IndexPath?
    
    @IBAction func removeFavorite(_ sender: UIButton) {
        print("1234")
        
        guard let indexPath = indexPath else { return }
        
        self.delegate?.removeTableViewCell(at: indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songImageWidth.constant = UIScreen.main.bounds.height / 10
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
