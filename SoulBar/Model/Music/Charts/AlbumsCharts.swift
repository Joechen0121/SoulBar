//
//  AlbumsCharts.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct AlbumsChartsResponseObject: Codable {
    
    let results: AlbumsChartsObject?
    
}

struct AlbumsChartsObject: Codable {
 
    let albums: [AlbumsCharts]?
    
}

struct AlbumsCharts: Codable {
    
    let chart: String
    
    let name: String
    
    let orderId: String

    let next: String?
    
    let data: [AlbumsChartsInfo]?

}

struct AlbumsChartsInfo: Codable {

    let id: String

    let type: String

    let href: String

    let attributes: AlbumsChartsAttributes?

}

struct AlbumsChartsAttributes: Codable {

    let copyright: String?

    let genreNames: [String]
    
    let releaseDate: String?
    
    let isMasteredForItunes: Bool
    
    let upc: String
    
    let url: String

    let artwork: Artwork?

    let playParams: PlayParameters?

    let recordLabel: String?
    
    let isCompilation: Bool
    
    let trackCount: Int
    
    let isSingle: Bool
    
    let name: String
    
    let artistName: String
    
    let contentRating: String?
    
    let editorialNotes: DescriptionAttribute?
    
    let isComplete: Bool
}

