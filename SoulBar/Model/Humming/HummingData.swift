//
//  HummingData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/1.
//

import Foundation

struct HummingData: Codable {
    
    var metadata: Metadata?
}

struct Metadata: Codable {
    
    var humming: [Humming]?
}

struct Humming: Codable {
    
    var album: HummingInfo?
    
    var artists: [HummingInfo]?
    
    var title: String?

    var score: Float?
}

struct HummingInfo: Codable {
    
    var name: String?
}
