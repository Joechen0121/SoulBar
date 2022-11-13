//
//  K.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/2.
//

import UIKit

struct K {
    
    struct FStore {
        
        static let user = "user"
        
        static let music = "music"
        
        struct Favorite {
            static let collectionName = "favorite"
            static let artists = "artists"
            static let songs = "songs"
            static let playlists = "playlists"
            static let albums = "albums"
            
        }
        
        struct List {
            static let collectionName = "list"
        }
        
    }
    
    static let ImageSizeForLargeState: CGFloat = 40
    static let ImageRightMargin: CGFloat = 16
    static let ImageBottomMarginForLargeState: CGFloat = 12
    static let ImageBottomMarginForSmallState: CGFloat = 6
    static let ImageSizeForSmallState: CGFloat = 32
    static let NavBarHeightSmallState: CGFloat = 44
    static let NavBarHeightLargeState: CGFloat = 96.5
    
    struct Colors {
        
        static let customRed = UIColor(red: 246 / 255.0, green: 83 / 255.0, blue: 103 / 255.0, alpha: 1.0)
    }
    
}
