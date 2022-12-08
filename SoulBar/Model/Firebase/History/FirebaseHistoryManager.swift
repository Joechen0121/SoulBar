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
    
    func addHistoryPlayData(with songID: String, completion: @escaping () -> Void) {
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let favorite = Firestore.firestore().collection(K.FStore.user).document(userID).collection("play")
        
        let document = favorite.document()
        
        let data: [String: Any] = [
            
            "list": [
                
                "time": Date().timeIntervalSince1970,
                
                "songID": songID
            ]
        ]
        
        favorite.whereField("list.songID", isEqualTo: songID).getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.documents.isEmpty {
                
                document.setData(data)
            } else {
                
                let document = snapshot.documents.first
                
                document?.reference.updateData(data)
            }
        }
        
        completion()
    }
    
    func fetchHistoryPlayData(completion: @escaping ([FirebaseHistoryPlayData]) -> Void) {
        
        var data = [FirebaseHistoryPlayData]()
        
        guard let userID = KeychainManager.sharedInstance.id else { return }
        
        let favorite = Firestore.firestore().collection("user").document(userID).collection("play")
        
        favorite.getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: FirebaseHistoryPlayData.self) else { return }
                
                data.append(dataPath)
                
            }
            completion(data)
        }
    }
}
