//
//  KeychainManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/15.
//

import Foundation
import SwiftKeychainWrapper

class KeychainManager {
    
    static let sharedInstance = KeychainManager()
    
    private init() {}
    
    var name: String? {
        
        get {
            
            if let name = KeychainWrapper.standard.string(forKey: "name") {
                
                return name
            }
            else {
                
                return nil
            }
        }
        
        set(username) {
            
            guard let username = username else { return }
            
            KeychainWrapper.standard.set(username, forKey: "name")
            
            return
    
        }
    }
    
    var id: String? {
        
        get {
            
            if let id = KeychainWrapper.standard.string(forKey: "id") {
                
                return id
            }
            else {
                
                return nil
            }
        }
        
        set(accessID) {
            
            guard let accessID = accessID else { return }
            
            KeychainWrapper.standard.set(accessID, forKey: "id")
            
            return
    
        }
    }
    
    var refreshToken: String? {
        
        get {
            
            if let token = KeychainWrapper.standard.string(forKey: "refreshToken") {
                
                return token
            }
            else {
                
                return nil
            }
        }
        
        set(token) {
            
            guard let token = token else { return }
            
            KeychainWrapper.standard.set(token, forKey: "refreshToken")
            
            return
    
        }
    }
    
    func removeRefreshToken() {
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "refreshToken")
    }
    
    func removeID() {
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "id")
    }
    
    func removeUsername() {
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "name")
    }
}
