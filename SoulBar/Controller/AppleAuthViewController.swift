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
    
    private let signInButton = ASAuthorizationAppleIDButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.center = view.center
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
                    
                    FirebaseUserManager.sharedInstance.fetchUserData { users in
                       
                        users.forEach { user in
                            if user.id == id {
                                
                                print(id)
                                
                                KeychainManager.sharedInstance.name = user.name
                                
                                KeychainManager.sharedInstance.id = id
                            }
                        }
                    }
                }
            }
            else {
                
                KeychainManager.sharedInstance.id = id
                
                FirebaseUserManager.sharedInstance.fetchUserData { users in
                    
                    users.forEach { user in
                        if user.id == id {
                            
                            print(id)
                            
                            KeychainManager.sharedInstance.name = user.name
                            
                            KeychainManager.sharedInstance.id = id
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
            let controller = UIAlertController(title: "使用者取消登入", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
            
        case ASAuthorizationError.failed:
           
            let controller = UIAlertController(title: "授權請求失敗", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        case ASAuthorizationError.invalidResponse:
          
            let controller = UIAlertController(title: "授權請求無回應", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        case ASAuthorizationError.notHandled:
          
            let controller = UIAlertController(title: "授權請求未處理", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)

            controller.addAction(action)
            
            present(controller, animated: true)
        case ASAuthorizationError.unknown:
           
            let controller = UIAlertController(title: "授權失敗，原因不知", message: "", preferredStyle: .alert)
            
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
