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
    
    func removeEventsTypeData(with type: Int, uid: String) {
        
        let event = Firestore.firestore().collection("user").document("event").collection(String(type))
        
        let document = event.document(uid)
        
        document.delete() { err in
            if let err = err {
                
                print("Error removing document: \(err)")
                
            } else {
                
                print("Document successfully removed!")
            }
        }
    }
    
    func addEventsTypeData(with type: Int, uid: String, eventName: String, eventTime: String, location: String, url: String, chatroom: String, completion: @escaping () -> Void) {
        
        let event = Firestore.firestore().collection("user").document("event").collection(String(type))
        
        let document = event.document(uid)
        
        let data: [String: Any] = [
            
            "uid": uid,
            
            "eventName": eventName,
            
            "eventTime": eventTime,
            
            "location": location,
            
            "url": url,
            
            "chatroom": chatroom
        ]
        
        event.whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            
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
    
    func fetchEventsTypeData(with type: Int, completion: @escaping () -> Void) {
        
        var data = [FirebaseEventsData]()
        
        let event = Firestore.firestore().collection("user").document("event").collection(String(type))
        
        event.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: FirebaseEventsData.self) else { return }
                
                data.append(dataPath)
                
            }
            print(data)
        }
        
        completion()
    }
    
    
}
