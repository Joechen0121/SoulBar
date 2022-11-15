//
//  RecognizeErrorViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/11.
//

import UIKit

class RecognizeErrorViewController: UIViewController {

    @IBOutlet weak var tryAgainButton: UIButton!
    
    static let storyboardID = "RecognizeErrorVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButton()

    }
    
    func configureButton() {
        
        tryAgainButton.layer.cornerRadius = 20
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    

}
