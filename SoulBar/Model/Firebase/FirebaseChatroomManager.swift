//
//  ChatroomManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseChatroomManager {
    
    static let sharedInstance = FirebaseChatroomManager()
    
    let chatroomDB = Firestore.firestore().collection("chatroom")
    
    func addChatroomMessagesData(chatroomID: String, messageID: String, sender: String, content: String, contentType: Int) {
        
        let document = chatroomDB.document(chatroomID).collection("messages").document()

        let data: [String: Any] = [

            "messageID": messageID,
            
            "sender": sender,
            
            "time": Date().timeIntervalSince1970,
            
            "content": content,
            
            "contentType": contentType

        ]

        document.getDocument { documentResult, error in

            if let documentResult = documentResult, documentResult.exists {

                document.updateData(data)

            } else {

                document.setData(data)
            }
        }
    }
    
    func fetchChatroomMessagesData(with id: String, completion: @escaping ([ChatroomMessagesData]) -> Void) {
        
        var data = [ChatroomMessagesData]()
        
        chatroomDB.document(id).collection("messages").order(by: "time").getDocuments { snapshot, error in

            guard let snapshot = snapshot else { return }

            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: ChatroomMessagesData.self) else { return }
                
                data.append(dataPath)
                
            }
            completion(data)
        }
    }
    
    func addChatroomMembersData(chatroomID: String, id: String) {
        
        let document = chatroomDB.document(chatroomID).collection("members").document()

        let data: [String: Any] = [

            "members": id

        ]

        document.getDocument { documentResult, error in

            if let documentResult = documentResult, documentResult.exists {

                document.updateData([

                    "members": FieldValue.arrayUnion([data])

                ])

            } else {

                document.setData(data)
            }
        }
    }
    
    func fetchChatroomMembersData(chatroomID: String, memberID: String, completion: @escaping ([ChatroomMembersData]) -> Void) {
        
        var data = [ChatroomMembersData]()
        
        chatroomDB.document(chatroomID).collection("members").getDocuments { snapshot, error in

            guard let snapshot = snapshot else { return }

            snapshot.documents.forEach { snapshot in
                
                guard let dataPath = try? snapshot.data(as: ChatroomMembersData.self) else { return }
                
                data.append(dataPath)
                
            }
            print(data)
            completion(data)
        }
    }
}
