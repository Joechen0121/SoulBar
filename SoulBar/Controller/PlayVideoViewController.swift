//
//  PlayVideoViewController.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/17.
//

import UIKit
import YoutubeKit

class PlayVideoViewController: UIViewController {

    static let storyboardID = "PlayVideoVC"
    
    private var player: YTSwiftyPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let song = PlaySongManager.sharedInstance.songs?[PlaySongManager.sharedInstance.current] else { return }
        
        if let songName = song.attributes?.name, let artist = song.attributes?.artistName {
            
            YoutubeManager.sharedInstance.searchYoutubeVideo(song: songName, artist: artist) { [weak self] result in
                print(result)
                
                guard let videoID = result.items?[0].id?.videoId, let self = self else { return }
                
                self.player = YTSwiftyPlayer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), playerVars: [
                    .videoID(videoID),
                    .loopVideo(true),
                    .showRelatedVideo(false)
                ])
                
                self.view = self.player
                
                // self.player.delegate = self
                
                self.player.autoplay = true
                
                self.player.loadPlayer()
                
                let request = VideoListRequest(part: [.id, .snippet, .contentDetails], filter: .chart)
                
                YoutubeAPI.shared.send(request) { result in
                    
                    switch result {
                        
                    case .success(let response):
                        print(response)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
