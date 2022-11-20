//
//  YoutubeData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/17.
//

import Foundation

struct YoutubeData: Codable {
    
    let kind: String?
    
    let etag: String?
    
    let regionCode: String?
    
    let items: [Items]?

}

struct Items: Codable {
    
    let kind: String?
    
    let etag: String?
    
    let id: VideoID?
    
    let snippet: Snippet?
    
    let channelTitle: String?
    
    let liveBroadcastContent: String?
    
    let publishTime: String?
    
}

struct VideoID: Codable {
    
    let kind: String?
    
    let videoId: String?
}

struct Snippet: Codable {
    
    let publishedAt: String?
    
    let channelId: String?
    
    let title: String?
    
    let thumbnails: Thumbnails?
    
}

struct Thumbnails: Codable {
    
    //let default: ImageInfo?
    
    let medium: ImageInfo?
    
    let high: ImageInfo?
    
}

struct ImageInfo: Codable {
    
    let url: String?
    
    let width: Int?
    
    let height: Int?
    
}
