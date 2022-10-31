//
//  PlaylistsSearch.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct PlaylistsSearchResponseObject: Codable {
    
    let results: PlaylistsSearchObject?
    
}

struct PlaylistsSearchObject: Codable {
 
    let playlists: PlaylistsSearch?
    
}

struct PlaylistsSearch: Codable {

    let data: [PlaylistsSearchInfo]?

    let href: String?

    let next: String?

}

struct PlaylistsSearchInfo: Codable {
    
    let id: String
    
    let type: String
    
    let href: String?
    
    let attributes: PlaylistsSearchAttributes //Playlists.Attributes
    
    let relationships: PlaylistsSearchRelationships
    
}

struct PlaylistsSearchAttributes: Codable {
    
    let artwork: Artwork?
    
    let curatorName: String?
    
    let description: DescriptionAttribute?
    
    let isChart: Bool
    
    let name: String
    
    let playlistType: String
    
    let playParams: PlayParameters

    let url: String
    
    let trackTypes: [String]?
}

struct DescriptionAttribute: Codable {
    
    let short: String?
    
    let standard: String?
}

struct PlayParameters: Codable {
    
    let id: String
    
    let kind: String
}

struct PlaylistsSearchRelationships: Codable {
    
    let curator: PlaylistsCurator
    
    let tracks: PlaylistsTracks
}

struct PlaylistsCurator: Codable {
    
    let href: String?
    
    let data: [PlaylistsCuratorData]?
    
}

struct PlaylistsCuratorData: Codable {
    
    let id: String
    
    let type: String
    
    let href: String?
}

struct PlaylistsTracks: Codable {
    
    let href: String?
    
    let data: [SongsSearchInfo]?
}
