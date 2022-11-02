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
    
    let favoriteDB = Firestore.firestore().collection(K.FStore.user).document(K.FStore.music).collection(K.FStore.Favorite.collectionName)
    
    let listDB = Firestore.firestore().collection(K.FStore.user).document(K.FStore.music).collection(K.FStore.List.collectionName)
    
    func addFavoriteMusicData(with term: String, id: String) {
        
        let document = favoriteDB.document(term)
        
        let data: [String: Any] = [
            
            "id": [id]
            
        ]
        
        document.getDocument { documentResult, error in
            
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
        
        favoriteDB.getDocuments { snapshot, error in
            
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
        
        let document = favoriteDB.document(type)
        
        document.updateData([
            "id": FieldValue.arrayRemove([id])
        ])
    }
    
    
    func removeFavoriteListData(with name: String) {
        
        let favorite = Firestore.firestore().collection(K.FStore.user).document("music").collection("list")
        
        let document = favorite.document(name)
        
        document.delete() { err in
            if let err = err {
                
                print("Error removing document: \(err)")
                
            } else {
                
                print("Document successfully removed!")
            }
        }
    }
    
    func fetchFavoriteListData(with name: String, completion: @escaping () -> Void) {
        
        listDB.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                print(snapshot.documentID)
                if snapshot.documentID == name {
                    
                    guard let data = try? snapshot.data(as: FirebaseFavoriteListData.self) else { return }
                    
                    print(data.songs)
                    
                }
                
            }
            
            completion()
        }
    }
    
    func addFavoriteListData(with name: String, id: String, completion: @escaping () -> Void) {
        
        let document = listDB.document(name)
        
        let data: [String: Any] = [
            
            "name": name,
            
            "songs": [id]
            
        ]
        
        document.getDocument { documentResult, error in
            
            if let documentResult = documentResult, documentResult.exists {
                print("Update")
                
                document.updateData([
                    
                    "songs": FieldValue.arrayUnion([id])
                    
                ])
                
            } else {
                print("Set")
                document.setData(data)
            }
        }
        
        completion()
    }
}
