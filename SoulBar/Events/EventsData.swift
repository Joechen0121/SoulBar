//
//  EventsData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct MusicEvents: Codable {
    
    let version: String
    
    let UID: String
    
    let title: String
    
    let category: String
    
    let showInfo: [ShowInfo]
    
    let showUnit: String
    
    let discountInfo: String
    
    let descriptionFilterHtml: String

    let imageUrl: String
    
    let masterUnit: [String]
    
    let subUnit: [String]
    
    let supportUnit: [String]
    
    let otherUnit: [String]
    
    let webSales: String
    
    let sourceWebPromote: String
    
    let comment: String
    
    let editModifyDate: String
    
    let sourceWebName: String
    
    let startDate: String
    
    let endDate: String
    
    let hitRate: Int
    
    var url: String?
    
    var type: Int?
}

struct ShowInfo: Codable {
    
    let time: String
    
    let location: String
    
    let locationName: String
    
    let onSales: String
    
    let price: String
    
    let latitude: String?
    
    let longitude: String?
    
    let endTime: String
    
}
