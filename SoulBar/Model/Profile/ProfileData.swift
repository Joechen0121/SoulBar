//
//  ProfileData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/6.
//

import Foundation

enum ProfileType: Int {
    
    case LikedSongs = 0
    
    case MyEvent
    
    case LikedArtists
    
    case RecogHistory
    
    case Privacy
    
}

struct Profile {
    
    var profileName: String
    
    var profileImage: String
    
}

class ProfileData {
    
    static let data = [
    
        Profile(profileName: "Liked Songs", profileImage: "heart.fill"),
        Profile(profileName: "My Events", profileImage: "event"),
        Profile(profileName: "Liked Artists", profileImage: "likedArtist"),
        Profile(profileName: "Recognize History", profileImage: "history"),
        Profile(profileName: "Privacy", profileImage: "privacy")
    ]
}
