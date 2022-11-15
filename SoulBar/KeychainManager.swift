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
        
        set(username) {
            
            guard let username = username else { return }
            
            let _ = KeychainWrapper.standard.set(username, forKey: "name")
            
            return
    
        }
        
        get {
            
            if let name = KeychainWrapper.standard.string(forKey: "name") {
                
                return name
            }
            else {
                
                return nil
            }
        }
    }
    
    var id: String? {
        
        set(accessID) {
            
            guard let accessID = accessID else { return }
            
            let _ = KeychainWrapper.standard.set(accessID, forKey: "id")
            
            return
    
        }
        
        get {
            
            if let id = KeychainWrapper.standard.string(forKey: "id") {
                
                return id
            }
            else {
                
                return nil
            }
        }
    }
    
    func removeID() {
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "id")
    }
    
    func removeUsername() {
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "name")
    }
}
