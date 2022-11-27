//
//  AuthData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/23.
//

import Foundation

struct TokenInformation: Codable {
    
    let accessToken: String?
    
    let tokenType: String?
    
    let expiresIn: Int?
    
    let refreshToken: String?
    
    let idToken: String
    
    enum CodingKeys: String, CodingKey {
        
        case accessToken = "access_token"
        
        case tokenType = "token_type"
        
        case expiresIn = "expires_in"
        
        case refreshToken = "refresh_token"
        
        case idToken = "id_token"
        
    }
}
