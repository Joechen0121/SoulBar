//
//  YoutubeManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/17.
//

import Foundation
import Alamofire

class YoutubeManager {
    
    static let sharedInstance = YoutubeManager()
    
    static let youtubeSearchURL = "https://www.googleapis.com/youtube/v3/search?"
    
    func fetchDeveloperToken() -> String? {
        
        let developerAuthenticationToken: String? = "AIzaSyClrbLXP8jCneoelOAcq2VACJa0mTwbJLY"
        
        return developerAuthenticationToken
    }
    
    func searchYoutubeVideo(song: String, artist: String, completion: @escaping (YoutubeData) -> Void) {

        let searchURL = YoutubeManager.youtubeSearchURL

        let param = [
            
            "key": "AIzaSyClrbLXP8jCneoelOAcq2VACJa0mTwbJLY",

            "type": "video",

            "part": "snippet",

            "q": "\(artist) \(song)"

        ] as [String: Any]

        AF.request(searchURL, method: .get, parameters: param).responseDecodable(of: YoutubeData.self) { response in
            if let data = response.value {
                
                completion(data)
            }
        }
    }
}
