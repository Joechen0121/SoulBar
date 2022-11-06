//
//  EventsData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseEventsData: Codable {
    
    let uid: String
    
    let eventName: String
    
    let eventTime: String
    
    let location: String
    
    let url: String
    
    let chatroom: String
    
    let type: Int
    
    let webURL: String
}
