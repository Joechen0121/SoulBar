//
//  ProfileArtistsTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/13.
//

import UIKit

class ProfileArtistsTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: ProfileArtistsTableViewCell.self)

    @IBOutlet weak var artistImage: UIImageView!
    
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var artistImageHeightConstraint: NSLayoutConstraint!
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        artistImageHeightConstraint.constant = UIScreen.main.bounds.height / 10
        
        artistImage.layer.masksToBounds = true

        artistImage.layer.cornerRadius = artistImageHeightConstraint.constant / 2
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
