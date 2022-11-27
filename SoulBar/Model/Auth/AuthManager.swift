//
//  AuthManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/23.
//

import Foundation
import Alamofire

class AuthManager {
    
    static let sharedInstance = AuthManager()
    
    let appleID = "3HBD942P6N"
    
    let teamID = "7228B97X2U"
    
    let clientID = "com.joechen.SoulBar"
    
    let aud = "https://appleid.apple.com"
    
    let tokenURL = "https://appleid.apple.com/auth/token"
    
    let revokeURL = "https://appleid.apple.com/auth/revoke"
    
    let p8 =
     """
     -----BEGIN PRIVATE KEY-----
     MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgVPguQLxOwPSLlkdR
     xAT/ECTuSJQQgypdJKIz75ngm56gCgYIKoZIzj0DAQehRANCAATirMwrTAhEasVR
     nAGCzyb+aGCVS8LRxJxeWiZVq8QeOX17SGvJGNcOLt3WjgIBVIrGFU0cISrNyhH8
     2z2/R35Y
     -----END PRIVATE KEY-----
     """
    
    func fetchTokenInfo(clientID: String, clientSecret: String, authCode: String, completion: @escaping (TokenInformation) -> Void) {

        var headers = HTTPHeaders()

        headers = [

            "Content-type": "application/x-www-form-urlencoded"

        ]
        
        let param = [

            "client_id": clientID,

            "client_secret": clientSecret,

            "code": authCode,
            
            "grant_type": "authorization_code"

        ] as [String : Any]

        AF.request(tokenURL, method: .post, parameters: param,headers: headers).responseDecodable(of: TokenInformation.self) { (response) in
            
            if let data = response.value {

                completion(data)

            }
            
            debugPrint(response)
        }
    }
    
    func revokeToken(clientID: String, clientSecret: String, refreshToken: String, completion: @escaping () -> Void) {

        var headers = HTTPHeaders()
        
        headers = [

            "Content-type": "application/x-www-form-urlencoded"

        ]
        
        let param = [

            "client_id": clientID,

            "client_secret": clientSecret,

            "token": refreshToken,
            
            "token_type_hint": "refresh_token"

        ] as [String : Any]

        AF.request(revokeURL, method: .post, parameters: param, headers: headers).response(completionHandler: { response in
            
            completion()
            debugPrint(response)
        })
    }
    
    
}
