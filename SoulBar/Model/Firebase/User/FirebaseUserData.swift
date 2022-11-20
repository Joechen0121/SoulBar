//
//  FirebaseUserData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseUserData: Codable {
    
    let id: String
    
    let email: String
    
    let name: String
}
