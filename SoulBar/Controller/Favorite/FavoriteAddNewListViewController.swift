//
//  FavoriteAddNewListViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/6.
//

import UIKit

class FavoriteAddNewListViewController: UIViewController {
    
    static let storyboardID = "AddNewListVC"
    
    @IBOutlet weak var newListTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presentationController?.presentingViewController.viewWillAppear(true)
    }

    @IBAction func addNewListButton(_ sender: UIButton) {
        
        if KeychainManager.sharedInstance.id == nil {
            
            if let authVC = storyboard?.instantiateViewController(withIdentifier: AppleAuthViewController.storyboardID) as? AppleAuthViewController {
                
                authVC.modalPresentationStyle = .overCurrentContext
                
                self.present(authVC, animated: false)
                
                return
            }
        }
        
        guard let text = newListTextField.text else { return }
        
        FirebaseFavoriteManager.sharedInstance.addFavoriteListData(with: text, id: "") { [weak self] in
            
            guard let self = self else { return }
            
            self.dismiss(animated: true)
        }
    }
}
