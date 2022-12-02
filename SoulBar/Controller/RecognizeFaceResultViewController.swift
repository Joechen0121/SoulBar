//
//  RecognizeFaceResultViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/1.
//

import UIKit

protocol RecognizeFaceResultDelegate {
    
    func updateSearchInofrmation(searchName: String)
}

class RecognizeFaceResultViewController: UIViewController {
    
    static let storyboardID = "RecognizeFaceResultVC"
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var pictureImage: UIImageView!
    
    @IBOutlet weak var result: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var resultView: UIView!
    
    var delegate: RecognizeFaceResultDelegate?
    
    var image: UIImage?
    
    var celeFaceName: String?
    
    var isSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 20
        
        resultView.layer.cornerRadius = 20
        
        resultView.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cancelButton.layer.cornerRadius = cancelButton.bounds.height / 2
        
        configureButton() 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch isSuccess {
            
        case true:
            
            guard let image = image, let celeFaceName = celeFaceName else { return }
            
            DispatchQueue.main.async {
                
                self.result.text = celeFaceName
                
                self.pictureImage.image = image
            }
            
            
        case false:
            
            guard let image = image else { return }
            
            DispatchQueue.main.async {
                
                self.result.text = "Not Found, Please take a picture again."
                
                self.pictureImage.image = image
            }
        }
    }
    
    func configureButton() {
        
        cancelButton.backgroundColor = K.Colors.customRed
        
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        
        searchButton.backgroundColor = UIColor.gray
        
        searchButton.layer.cornerRadius = searchButton.frame.height / 2
        
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        
        guard let name = celeFaceName else { return }
        
        delegate?.updateSearchInofrmation(searchName: name)
        
        dismiss(animated: true)
        
    }
    
}
