//
//  AlbumsSearch.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct AlbumsSearchResponseObject: Codable {
    
    let results: AlbumsSearchObject?
    
}

struct AlbumsSearchObject: Codable {
 
    let albums: AlbumsSearch?
    
}

struct AlbumsSearch: Codable {

    let data: [AlbumsSearchInfo]?

    let href: String?

    let next: String?

}

struct AlbumsSearchInfo: Codable {
    
    let id: String
    
    let type: String
    
    let href: String?
    
    let attributes: AlbumsSearchAttributes? //Albums.Attributes
    
    let relationships: AlbumsRelationships?
}

struct AlbumsSearchAttributes: Codable {
    
    let artistName: String
    
    let artistUrl: String?
    
    let artwork: Artwork?
    
    let genreNames: [String]
    
    let isCompilation: Bool
    
    let isComplete: Bool
    
    let isMasteredForItunes: Bool
    
    let isSingle: Bool
    
    let name: String
    
    let trackCount: Int
}

struct AlbumsRelationships: Codable {
    
    let artists: AlbumsArtists
    
    let tracks: AlbumsTracks
}

struct AlbumsArtists: Codable {
    
    let href: String?
    
    let data: [ArtistsData]
    
}

struct ArtistsData: Codable {
    
    let id: String
    
    let type: String
    
    let href: String?
}

struct AlbumsTracks: Codable {
    
    let href: String?
    
    let data: [AlbumsTracksData]?
    
}

struct AlbumsTracksData: Codable {

    let id: String
    
    let type: String
    
    let href: String?
    
    let attributes: AlbumsTracksAttributes?
    
}

struct AlbumsTracksAttributes: Codable {
    
    let trackNumber: Int
    
    let releaseDate: String?
    
    let durationInMillis: Int
    
    let isrc: String
    
    let artwork: Artwork?
    
    let composerName: String?
    
    let url: String?
    
    let playParams: PlayParameters?
    
    let discNumber: Int
    
    let isAppleDigitalMaster: Bool?
    
    let hasLyrics: Bool
    
    let name: String?
    
    let previews: [Preview]?
    
    let artistName: String?
}
