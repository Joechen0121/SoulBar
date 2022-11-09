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
    
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 40
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
    
}
