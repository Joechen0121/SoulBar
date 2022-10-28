//
//  ArtistsSearch.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/28.
//

import Foundation

struct ArtistsSearchResponseObject: Codable {
    
    let results: ArtistsSearchObject?
    
}

struct ArtistsSearchObject: Codable {
 
    let artists: ArtistsSearch?
    
}

struct ArtistsSearch: Codable {

    let data: [ArtistsSearchInfo]?

    let href: String?

    let next: String?

}

struct ArtistsSearchInfo: Codable {

    let id: String?

    let type: String?

    let href: String?

    let attributes: ArtistsSearchAttributes? //Songs.Attributes

    let relationships: ArtistsRelationships //Songs.Relationships

}

struct ArtistsSearchAttributes: Codable {

    let albumName: String?

    let artistName: String?

    let artwork: Artwork?

    let durationInMillis: Int?

    let genreNames: [String]

    let hasLyrics: Bool?

    let isAppleDigitalMaster: Bool?

    let name: String?

    let previews: [Preview]?

    let url: String?
}

struct ArtistsRelationships: Codable {
    
    let albums: Albums
    
}

struct Albums: Codable {
    
    let href: String?
    
    let next: String?
    
    let data: [AlbumsData]
    
}

struct AlbumsData: Codable {
    
    let id: String?
    
    let type: String?
    
    let href: String?
    
}
