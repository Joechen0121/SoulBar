//
//  ProfileData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/6.
//

import Foundation

struct Profile {
    
    var profileName: String
    
    var profileImage: String
    
}

class ProfileData {
    
    static let data = [
    
        Profile(profileName: "Liked Songs", profileImage: "heart.fill"),
        Profile(profileName: "My Events", profileImage: "note.text"),
        Profile(profileName: "Liked Artists", profileImage: "person.crop.circle.badge.plus"),
        Profile(profileName: "Recognize History", profileImage: "timer"),
        Profile(profileName: "Blacklist", profileImage: "person.fill.xmark.rtl")
    ]
}
