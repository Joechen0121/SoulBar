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
        
        let document = Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.Favorite.collectionName).document(term)
        
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
        
        Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.Favorite.collectionName).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                if snapshot.documentID == type {
                    
                    guard let data = try? snapshot.data(as: FirebaseFavoriteData.self) else { return }
                    
                    completion(data)
                }
                
            }
        }
    }
    
    
    func removeFavoriteMusicData(with type: String, id: String) {
        
        let document = Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.Favorite.collectionName).document(type)
        
        document.updateData([
            "id": FieldValue.arrayRemove([id])
        ])
    }
    
    
    func removeFavoriteListData(with name: String) {
        
        let favorite = Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.List.collectionName)
        
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
        
        Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.List.collectionName).getDocuments { snapshot, error  in
            
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
        
        let document = Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.List.collectionName).document(name)
        
        let data: [String: Any] = [
            
            "name": name,
            
            "songs": [id]
            
        ]
        
        document.getDocument { documentResult, error in
            
            if let documentResult = documentResult, documentResult.exists {
                
                document.updateData(["songs": FieldValue.arrayUnion([id])])
                
            } else {

                document.setData(data)
            }
            
            completion()
        }
    }
    
    func removeFavoriteSongListData(with name: String, songID: String, completion: @escaping () -> Void) {
        
        let document = Firestore.firestore().collection(K.FStore.user).document(KeychainManager.sharedInstance.id!).collection(K.FStore.List.collectionName).document(name)
    
        document.updateData(["songs": FieldValue.arrayRemove([songID])]) { error in

            guard error == nil else { return }
            
            completion()
        }
    }
}
