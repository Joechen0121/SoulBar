//
//  FirebaseChatroomData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatroomMembersData: Codable {
    
    let members: String
}

struct ChatroomMessagesData: Codable {
    
    let messageID: String
    
    let sender: String
    
    let time: TimeInterval
    
    let content: String
    
    let contentType: Int
    
}
