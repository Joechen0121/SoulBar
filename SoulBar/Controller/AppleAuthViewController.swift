//
//  AppleAuthViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/14.
//

import UIKit
import AuthenticationServices
import CryptoKit

class AppleAuthViewController: UIViewController {
    
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

}

extension AppleAuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            guard let token = credentials.identityToken,  let appleToken = String(data: token, encoding: .utf8), let firstName = credentials.fullName?.givenName, let lastName = credentials.fullName?.familyName else { return }
           
            let id = credentials.user

            let fullName = credentials.fullName
            
            let email = credentials.email
            
            FirebaseUserManager.sharedInstance.addUserData(uuid: id, email: email!, name: lastName + firstName)
            
            print(id)
            print(appleToken)
            print(fullName)
            print(firstName)
            print(lastName)
            print(email)
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

extension AppleAuthViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
    
}
