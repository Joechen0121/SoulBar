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
import SwiftJWT

class AppleAuthViewController: UIViewController {
    
    static let storyboardID = "AppleAuthVC"
    
    @IBOutlet weak var notNowButton: UIButton!
    
    @IBOutlet weak var signInButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackgroundView()
        
        configureButton()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    private func configureBackgroundView() {
        
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
    }
    
    private func configureButton() {
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        signInButton.layer.cornerRadius = signInButton.frame.height / 2.5
        
        signInButton.layer.masksToBounds = true
        
        signInButton.layer.borderWidth = 1
        
        signInButton.layer.borderColor = UIColor.black.cgColor
        
        notNowButton.layer.cornerRadius = signInButton.frame.height / 2.5
        
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
    
    private func storeAuthToken(credentials: ASAuthorizationAppleIDCredential) {
        
        let header = Header(kid: AuthManager.sharedInstance.teamID)
        
        let claims = AuthClaims(iss: AuthManager.sharedInstance.appleID, iat: Date(), exp: Date(timeIntervalSinceNow: 3600), aud: AuthManager.sharedInstance.aud, sub: AuthManager.sharedInstance.clientID)
        
        var jwt = JWT(header: header, claims: claims)
        
        let jwtSigner = JWTSigner.es256(privateKey: Data(AuthManager.sharedInstance.p8.utf8))
        
        do {
            
            guard let authCode = String(data: credentials.authorizationCode!, encoding: .utf8) else { return }
            
            let signedJWT = try jwt.sign(using: jwtSigner)
            
            AuthManager.sharedInstance.fetchTokenInfo(
                clientID: AuthManager.sharedInstance.clientID,
                clientSecret: signedJWT,
                authCode: authCode) { result in
                    
                    guard let refreshToken = result.refreshToken else { return }
                    
                    KeychainManager.sharedInstance.refreshToken = refreshToken
                    
                }
            
        } catch {
            
            print(error)
        }
    }
}

extension AppleAuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            guard let token = credentials.identityToken, String(data: token, encoding: .utf8) != nil else { return }
            
            let id = credentials.user
            
            storeAuthToken(credentials: credentials)
            
            if let email = credentials.email, let firstName = credentials.fullName?.givenName, let lastName = credentials.fullName?.familyName {
                
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
