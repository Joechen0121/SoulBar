//
//  FirebaseUserManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseUserManager {
    
    static let sharedInstance = FirebaseUserManager()
    
    func addUserData(uuid: String, email: String, name: String) {
     
        let user = Firestore.firestore().collection("user")
        
        let document = user.document(uuid)
        
        let data: [String: Any] = [
            
            "uuid": uuid,
            
            "email": email,
            
            "name": name
        ]
        
        user.whereField("uuid", isEqualTo: uuid).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.documents.isEmpty  {
                
                print("Set")
                document.setData(data)
            } else {
                
                print("Update")
                
                let document = snapshot.documents.first
                
                document?.reference.updateData(data)
            }
        }
    }
    
    func fetchUserData(uuid: String) {
        
        let user = Firestore.firestore().collection("user")
        
        user.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                guard let data = try? snapshot.data(as: FirebaseUserData.self) else { return }
                
                print(data)
                
            }
        }
        
    }
    
    func removeUserData(uuid: String) {
        
        let user = Firestore.firestore().collection("user")
        
        let document = user.document(uuid)
        
        document.delete { err in
            if let err = err {
                
                print("Error removing document: \(err)")
                
            } else {
                
                print("Document successfully removed!")
            }
        }
    }
}
