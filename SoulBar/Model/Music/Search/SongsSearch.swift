//
//  SongsSearch.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation

struct SongsSearchResponseObject: Codable {
    
    let results: SongsSearchObject?
    
}

struct SongsSearchObject: Codable {
 
    let songs: SongsSearch?
    
}

struct SongsSearch: Codable {

    let data: [SongsSearchInfo]?

    let href: String?

    let next: String?

}

struct SongsSearchInfo: Codable {

    let id: String?

    let type: String?

    let href: String?

    let attributes: SongsSearchAttributes? //Songs.Attributes

    //let relationships: Relationships //Songs.Relationships

}

struct SongsSearchAttributes: Codable {

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

struct Artwork: Codable {

    let bgColor: String?

    let height: Int?

    let width: Int?

    let textColor1: String?

    let textColor2: String?

    let textColor3: String?

    let textColor4: String?

    let url: String?

}

struct Preview: Codable {

    let artwork: Artwork?

    let url: String

    let hlsUrl: String?
}
