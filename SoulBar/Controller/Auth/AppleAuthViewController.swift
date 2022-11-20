//
//  AppleAuthViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/14.
//

import UIKit
import AuthenticationServices
import CryptoKit
import SwiftKeychainWrapper

class AppleAuthViewController: UIViewController {
    
    static let storyboardID = "AppleAuthVC"
    
   // private let signInButton = ASAuthorizationAppleIDButton()
    @IBOutlet weak var notNowButton: UIButton!
    
    @IBOutlet weak var signInButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //view.addSubview(signInButton)
        
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
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        signInButton.layer.cornerRadius = signInButton.frame.height / 2.5
        
        signInButton.layer.masksToBounds = true
        
        signInButton.layer.borderWidth = 1
        
        signInButton.layer.borderColor = UIColor.black.cgColor
        
        notNowButton.layer.cornerRadius = signInButton.frame.height / 2.5

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //signInButton.center = view.center
    }
    
    @objc func didTapSignIn() {
        
        let provider = ASAuthorizationAppleIDProvider()
        
        let request = provider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        
        controller.presentationContextProvider = self
        
        controller.performRequests()
        
    }

    @IBAction func dismissButton(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
}

extension AppleAuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            guard let token = credentials.identityToken, let _ = String(data: token, encoding: .utf8) else { return }
            
            let firstName = credentials.fullName?.givenName
           
            let id = credentials.user

            let lastName = credentials.fullName?.familyName
            
            let email = credentials.email
            
            if let email = email, let firstName = firstName, let lastName = lastName {
                
                FirebaseUserManager.sharedInstance.addUserData(id: id, email: email, name: lastName + firstName) {
                                
                    KeychainManager.sharedInstance.name = lastName + firstName
                    
                    KeychainManager.sharedInstance.id = id
                }
            }
            else {
                
                KeychainManager.sharedInstance.id = id
                
                FirebaseUserManager.sharedInstance.fetchUserData { users in
                    
                    users.forEach { user in
                        
                        if user.id == id {
                            
                            KeychainManager.sharedInstance.name = user.name
    
                        }
                    }
                }
            }

            dismiss(animated: true)
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        switch error {
        case ASAuthorizationError.canceled:
            let controller = UIAlertController(title: "User cancels login", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
            
        case ASAuthorizationError.failed:
           
            let controller = UIAlertController(title: "Authorization request failed", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        case ASAuthorizationError.invalidResponse:
          
            let controller = UIAlertController(title: "Authorization request no response", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        case ASAuthorizationError.notHandled:
          
            let controller = UIAlertController(title: "Authorization request not processed", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        case ASAuthorizationError.unknown:
           
            let controller = UIAlertController(title: "Authorization failed for unknown reason", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        default:
            break
        }
        
    }
    
}

extension AppleAuthViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
    
}
