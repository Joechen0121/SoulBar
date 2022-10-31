//
//  PlaylistsCharts.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct PlaylistsChartsResponseObject: Codable {
    
    let results: PlaylistsChartsObject?
    
}

struct PlaylistsChartsObject: Codable {
 
    let playlists: [PlaylistsCharts]?
    
}

struct PlaylistsCharts: Codable {
    
    let chart: String
    
    let name: String
    
    let orderId: String

    let next: String?
    
    let data: [PlaylistsChartsInfo]?

}

struct PlaylistsChartsInfo: Codable {

    let id: String

    let type: String

    let href: String

    let attributes: PlaylistsChartsAttributes?

}

struct PlaylistsChartsAttributes: Codable {

    let curatorName: String?

    let lastModifiedDate: String
    
    let name: String
    
    let isChart: Bool
    
    let playlistType: String
    
    let description: DescriptionAttribute?

    let artwork: Artwork?

    let playParams: PlayParameters?

    let url: String
    
}
