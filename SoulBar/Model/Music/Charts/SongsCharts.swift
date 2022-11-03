//
//  SongsCharts.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct SongsChartsResponseObject: Codable {
    
    let results: SongsChartsObject?
    
}

struct SongsChartsObject: Codable {
 
    let songs: [SongsCharts]?
    
}

struct SongsCharts: Codable {
    
    let chart: String
    
    let name: String
    
    let orderId: String

    let next: String?
    
    let data: [SongsChartsInfo]?

}

struct SongsChartsInfo: Codable {

    let id: String

    let type: String

    let href: String?

    let attributes: SongsChartsAttributes?

}

struct SongsChartsAttributes: Codable {

    let albumName: String?

    let artistName: String

    let artwork: Artwork?

    let durationInMillis: Int

    let genreNames: [String]?

    let hasLyrics: Bool

    let isAppleDigitalMaster: Bool

    let name: String

    let previews: [Preview]?

    let url: String
    
    let trackNumber: Int
    
    let releaseDate: String?
}
