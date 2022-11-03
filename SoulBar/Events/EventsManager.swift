//
//  EventsManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/10/26.
//

import Foundation
import Alamofire
import CoreMedia
import CoreMIDI

enum MusicEventsCategory: Int, CaseIterable {
    
    case 音樂 = 1
    
    case 戲劇 = 2
    
    case 舞蹈 = 3
    
    case 親子 = 4
    
    case 獨立音樂 = 5
    
    case 展覽 = 6
    
    case 講座 = 7
    
    case 電影 = 8
    
    case 綜藝 = 11
    
    case 競賽 = 13
    
    case 徵選 = 14
    
    case 其他 = 15
    
    case 演唱會 = 17
    
    case 研習課程 = 19
    
    case 研習閱讀 = 200
}

class EventsManager {
    
    func getMusicEventsInformation(category: MusicEventsCategory, completion: @escaping ([MusicEvents]) -> Void) {
        
        let songsURL = "https://cloud.culture.tw/frontsite/trans/SearchShowAction.do?method=doFindTypeJ&category=\(category.rawValue)"
        
        AF.request(songsURL, method: .get).responseDecodable(of: [MusicEvents].self) { (response) in
            if let data = response.value {
            
                var events = [MusicEvents]()
                
                events = data
                
                for i in 0..<events.count {
                    
                    events[i].url = songsURL
                    events[i].type = category.rawValue
                }

                completion(events)

            }
             debugPrint(response)
        }
    }
}
