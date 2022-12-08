//
//  EventsManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseEventsManager {
    
    static let sharedInstance = FirebaseEventsManager()
    
    func removeEventsTypeData(with type: Int, uid: String) {
        
        guard let id = KeychainManager.sharedInstance.id else { return }
        
        let event = Firestore.firestore().collection(K.FStore.user).document(id).collection(String(type))
        
        let document = event.document(uid)
        
        document.delete { err in
            
            if let err = err {
                
                print("Error removing document: \(err)")
                
            } else {
                
                print("Document successfully removed!")
            }
        }
    }
    
    func addEventsTypeData(with type: Int, uid: String, webURL: String, eventName: String, eventTime: String, location: String, url: String, chatroom: String) {
        
        guard let id = KeychainManager.sharedInstance.id else { return }
        
        let event = Firestore.firestore().collection(K.FStore.user).document(id).collection(String(type))
        
        let document = event.document(uid)
        
        let data: [String: Any] = [
            
            "uid": uid,
            
            "eventName": eventName,
            
            "eventTime": eventTime,
            
            "location": location,
            
            "url": url,
            
            "chatroom": chatroom,
            
            "type": type,
            
            "webURL": webURL
        ]
        
        event.whereField("uid", isEqualTo: uid).getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.documents.isEmpty {
                
                document.setData(data)
            } else {
                
                let document = snapshot.documents.first
                
                document?.reference.updateData(data)
            }
        }
    }
    
    func fetchEventsTypeData(with type: Int, completion: @escaping ([FirebaseEventsData]) -> Void) {
        
        var data = [FirebaseEventsData]()
        
        guard let id = KeychainManager.sharedInstance.id else { return }
        
        let event = Firestore.firestore().collection(K.FStore.user).document(id).collection(String(type))
        
        event.getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: FirebaseEventsData.self) else { return }
                
                data.append(dataPath)
                
            }
            completion(data)
        }
    }
}
