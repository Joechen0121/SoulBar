//
//  FavoriteManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseFavoriteManager {
    
    static let sharedInstance = FirebaseFavoriteManager()
    
    func addFavoriteMusicData(with term: String, id: String) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let document = Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.Favorite.collectionName).document(term)
        
        let data: [String: Any] = [
            
            "id": [id]
            
        ]
        
        document.getDocument { documentResult, _ in
            
            if let documentResult = documentResult, documentResult.exists {
                
                document.updateData([
                    
                    "id": FieldValue.arrayUnion([id])
                    
                ])
                
            } else {
    
                document.setData(data)
            }
        }
    }
    
    func fetchFavoriteMusicData(with type: String, completion: @escaping (FirebaseFavoriteData) -> Void) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.Favorite.collectionName).getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            let exist = snapshot.documents.filter { $0.documentID == type }
            
            if !exist.isEmpty {
                
                guard let data = try? exist[0].data(as: FirebaseFavoriteData.self) else { return }
                
                completion(data)
                
            }
            else {
                
                completion(FirebaseFavoriteData(id: [""]))
            }
        }
    }
    
    
    func removeFavoriteMusicData(with type: String, id: String) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let document = Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.Favorite.collectionName).document(type)
        
        document.updateData([
            "id": FieldValue.arrayRemove([id])
        ])
    }
    
    
    func removeFavoriteListData(with name: String) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let favorite = Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.List.collectionName)
        
        let document = favorite.document(name)
        
        document.delete { err in
            if let err = err {
                
                print("Error removing document: \(err)")
                
            } else {
                
                print("Document successfully removed!")
            }
        }
    }
    
    func fetchFavoriteListData(completion: @escaping ([FirebaseFavoriteListData]) -> Void) {
        
        var data: [FirebaseFavoriteListData] = []
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.List.collectionName).getDocuments { snapshot, _  in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                print(snapshot.documentID)

                guard let dataPath = try? snapshot.data(as: FirebaseFavoriteListData.self) else { return }
                
                print(dataPath)
                data.append(dataPath)

            }
            
            completion(data)
        }
    }
    
    func addFavoriteListData(with name: String, id: String, completion: @escaping () -> Void) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let document = Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.List.collectionName).document(name)
        
        let data: [String: Any] = [
            
            "name": name,
            
            "songs": [id]
            
        ]
        
        document.getDocument { documentResult, _ in
            
            if let documentResult = documentResult, documentResult.exists {
                
                document.updateData(["songs": FieldValue.arrayUnion([id])])
                
            } else {

                document.setData(data)
            }
            
            completion()
        }
    }
    
    func removeFavoriteSongListData(with name: String, songID: String, completion: @escaping () -> Void) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let document = Firestore.firestore().collection(K.FStore.user).document(userID).collection(K.FStore.List.collectionName).document(name)
    
        document.updateData(["songs": FieldValue.arrayRemove([songID])]) { error in

            guard error == nil else { return }
            
            completion()
        }
    }
}
