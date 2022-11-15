//
//  HistoryManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseHistoryManager {
    
    static let sharedInstance = FirebaseHistoryManager()
    
    func addHistorySearchData(text: String, completion: @escaping () -> Void) {
        
        let favorite = Firestore.firestore().collection("user").document(KeychainManager.sharedInstance.id!).collection("search")
        
        let document = favorite.document()
        
        let data: [String: Any] = [
            
            "list": [
                
                "time": Date().timeIntervalSince1970,
                
                "text": text
            ]
        ]
        
        favorite.whereField("list.text", isEqualTo: text).getDocuments { snapshot, error in
            
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
        
        completion()
    }
    
    func fetchHistorySearchData(completion: @escaping () -> Void) {
        
        var data = [FirebaseHistorySearchData]()
        
        let favorite = Firestore.firestore().collection("user").document(KeychainManager.sharedInstance.id!).collection("search")
        
        favorite.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: FirebaseHistorySearchData.self) else { return }
                
                data.append(dataPath)
                
            }
            print(data)
        }
        
        completion()
    }
    
    
    func addHistoryPlayData(with songID: String, completion: @escaping () -> Void) {
        
        let favorite = Firestore.firestore().collection("user").document(KeychainManager.sharedInstance.id!).collection("play")
        
        let document = favorite.document()
        
        let data: [String: Any] = [
            
            "list": [
                
                "time": Date().timeIntervalSince1970,
                
                "songID": songID
            ]
        ]
        
        favorite.whereField("list.songID", isEqualTo: songID).getDocuments { snapshot, error in
            
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
        
        completion()
    }
    
    func fetchHistoryPlayData(completion: @escaping ([FirebaseHistoryPlayData]) -> Void) {
        
        var data = [FirebaseHistoryPlayData]()
        
        let favorite = Firestore.firestore().collection("user").document(KeychainManager.sharedInstance.id!).collection("play")
        
        favorite.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: FirebaseHistoryPlayData.self) else { return }
                
                data.append(dataPath)
                
            }
            completion(data)
        }
    }
}
