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
    
        Profile(profileName: "已按讚的歌曲", profileImage: "heart.fill"),
        Profile(profileName: "我的播放清單", profileImage: "music.note.house"),
        Profile(profileName: "收藏的清單", profileImage: "music.note.list"),
        Profile(profileName: "我的活動", profileImage: "note.text"),
        Profile(profileName: "追蹤的音樂人", profileImage: "person.crop.circle.badge.plus"),
        Profile(profileName: "播放紀錄", profileImage: "timer"),
        Profile(profileName: "已封鎖的黑名單", profileImage: "person.fill.xmark.rtl")
    ]
}
