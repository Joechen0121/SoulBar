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
    
    func addUserData(id: String, email: String, name: String, completion: @escaping () -> Void) {
        
        let user = Firestore.firestore().collection(K.FStore.user)
        
        let document = user.document(id)
        
        let data: [String: Any] = [
            
            "id": id,
            
            "email": email,
            
            "name": name
        ]
        
        user.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.documents.isEmpty  {
                
                print("Set")
                document.setData(data)
            } else {
                
                print("Update")
                
                let document = snapshot.documents.first
                
                document?.reference.updateData(data)
            }
            
            completion()
        }
    }
    
    func fetchUserData(completion: @escaping ([FirebaseUserData]) -> Void) {
        
        let user = Firestore.firestore().collection(K.FStore.user)
        
        user.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            var dataPath: [FirebaseUserData] = []
            
            snapshot.documents.forEach { snapshot in

                guard let data = try? snapshot.data(as: FirebaseUserData.self) else { return }
                
                dataPath.append(data)
                
                print(data)
                
            }
            
            completion(dataPath)
        }
        
    }
    
    func removeUserData(id: String) {
        
        let user = Firestore.firestore().collection(K.FStore.user)
        
        let document = user.document(id)
        
        document.delete { err in
            if let err = err {
                
                print("Error removing document: \(err)")
                
            } else {
                
                print("Document successfully removed!")
            }
        }
    }
}
