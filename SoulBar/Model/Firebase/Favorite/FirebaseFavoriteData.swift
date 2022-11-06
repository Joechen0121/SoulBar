//
//  FavoriteData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseFavoriteData: Codable {

    let id: [String]
}

struct FirebaseFavoriteListData: Codable {
    
    let name: String
    
    let songs: [String]
}
