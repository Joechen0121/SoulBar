//
//  HistoryData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseHistorySearchData: Codable {
    
    let list: FirebaseHistorySearchList
}

struct FirebaseHistorySearchList: Codable {
    
    let time: TimeInterval
    
    let text: String
}

struct FirebaseHistoryPlayData: Codable {
    
    let list: FirebaseHistoryPlayList
}

struct FirebaseHistoryPlayList: Codable {
    
    let time: TimeInterval
    
    let songID: String
}
