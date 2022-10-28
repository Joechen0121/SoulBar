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

    let href: String

    let next: String?

}

struct AlbumsSearchInfo: Codable {
    
    let id: String
    
    let type: String
    
    let href: String
    
    let attributes: AlbumsSearchAttributes //Albums.Attributes
    
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
    
    let artists: Artists
    
    let tracks: Tracks
}

struct Artists: Codable {
    
    let href: String
    
    let data: ArtistsData
    
}

struct ArtistsData: Codable {
    
    let id: String
    
    let type: String
    
    let href: String
}

struct Tracks: Codable {
    
    
    
}
