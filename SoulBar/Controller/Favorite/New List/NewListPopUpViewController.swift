//
//  NewListPopUpViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/7.
//

import UIKit

class NewListPopUpViewController: UIViewController {

    static let storyboardID = "NewListPopUpVC"
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var canclButton: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!

    @IBOutlet weak var newListTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let backgroundImageView = UIImageView(image: UIImage(named: "demoAlbum"))
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
        
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presentationController?.presentingViewController.viewWillAppear(true)
        
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    @IBAction func confirmButton(_ sender: UIButton) {
        
        if KeychainManager.sharedInstance.id == nil {
            let authVC = storyboard!.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as! AppleAuthViewController
            authVC.modalPresentationStyle = .overCurrentContext
            self.present(authVC, animated: false)
        }
    
        guard let text = newListTextField.text, !text.isEmpty else { return }
    
        FirebaseFavoriteManager.sharedInstance.addFavoriteListData(with: text, id: "") { [weak self] in
            
            guard let self = self else { return }
            
            self.dismiss(animated: true)
        }

    }
    
    func configureButton() {
        
        canclButton.backgroundColor = UIColor(red: 249 / 255, green: 68 / 255, blue: 73 / 255, alpha: 1)
        
        canclButton.layer.cornerRadius = canclButton.frame.height / 2
        
        confirmButton.backgroundColor = UIColor.gray
        
        confirmButton.layer.cornerRadius = canclButton.frame.height / 2
        
    }
    
    func configureView() {
        
        
        alertView.layer.borderColor = UIColor.black.cgColor
        
        alertView.layer.cornerRadius = alertView.frame.height / 10
    }
}
