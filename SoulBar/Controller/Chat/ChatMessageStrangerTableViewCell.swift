//
//  ChatMessageTableViewCell.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/4.
//


import UIKit
protocol ChatMessageStrangerTableViewCellDelegate {

    func presentReportMessage(at indexPath: IndexPath)
    
}

class ChatMessageStrangerTableViewCell: UITableViewCell {

    static let identifier = String(describing: ChatMessageStrangerTableViewCell.self)
    
    @IBOutlet weak var othersImage: UIImageView!
    
    @IBOutlet weak var messageBackground: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var delegate: ChatMessageStrangerTableViewCellDelegate?
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        othersImage.isUserInteractionEnabled = true
        
        othersImage.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func imageTapped() {
        print("tapped")
        guard let indexPath = indexPath else { return }

        delegate?.presentReportMessage(at: indexPath)
    }
    
}
