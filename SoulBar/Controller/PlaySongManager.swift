//
//  PlaySongManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/5.
//

import Foundation
import AVFoundation
import MediaPlayer

public protocol PlaySongDelegate: AnyObject {
    
    func didReceiveNotification(player: AVPlayer?, notification: Notification.Name)
    
    func didUpdatePosition(_ player: AVPlayer?, _ position: PlayerPosition)
    
    func selectData(index: Int, isFromMiniPlayer: Bool)
}

public struct PlayerPosition {
    
    public var duration: Int = 0
    
    public var current: Int = 0

}

enum PlayState {
    
    case unowned
    
    case play
    
    case pause
}

enum PlayRule {
    
    case single
    
    case random
    
    case loop
}


class PlaySongManager: NSObject {
    
    static let sharedInstance = PlaySongManager()
    
    private var position = PlayerPosition()
    
    let player = AVPlayer()
    
    weak var delegate: PlaySongDelegate?
    
    var current = 0
    
    var maxCount = 0
    
    var playerObserver: Any?
    
    var timerInvalid = false
    
    var queuePlayer: AVQueuePlayer?
    
    var playerItem: [AVPlayerItem]?
    
    var currentSong: SongsSearchInfo?
    
    var songs: [SongsSearchInfo]?
    
    var currentTime: Double = 0
    
    func setupPlayer(with url: URL) {
        
        let asset = AVURLAsset(url: url)
        
        let item = AVPlayerItem(asset: asset)

        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        DispatchQueue.main.async {
            self.player.replaceCurrentItem(with: item)
            self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
            self.addTimeObserve()
            self.player.allowsExternalPlayback = true
            self.player.usesExternalPlaybackWhileExternalScreenIsActive = true
            
        }
    }
    
    func addTimeObserve() {
        
        self.timerInvalid = false
        self.playerObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1 / 30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main) { [weak self] _ in

            guard let self = self else { return }
            
            // Seekable time ranges
            if let currentItem = self.player.currentItem {
                
                let loadedRanges = currentItem.seekableTimeRanges
                guard let range = loadedRanges.first?.timeRangeValue, range.start.timescale > 0, range.duration.timescale > 0 else {
                    return
                }
                 
                let duration = (CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration))
                
                if !range.duration.flags.contains(.valid) || duration < 0 {
                    return
                }
                
                let currentTime = currentItem.currentTime()
                self.position = PlayerPosition(duration: Int(duration), current: Int(CMTimeGetSeconds(currentTime)))
                
                self.currentTime = self.player.currentTime().seconds
                
                self.delegate?.didUpdatePosition(self.player, self.position)
            }
        }
    }
    
    func removePlayerObserve() {
        
        self.player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: nil)
        self.player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
        
    }
    
    func removeTimeObserve() {
        
        if let observer = self.playerObserver {
            self.player.removeTimeObserver(observer)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                delegate?.didReceiveNotification(player: self.player, notification: .PlayerReadyToPlayNotification)
                self.startPlayer()
                print("PlayerStatus ReadyToPlay")
                
            case .failed:
                delegate?.didReceiveNotification(player: self.player, notification: .PlayerFailedNotification)
                print("PlayerStatus Failed")
                
            case .unknown:
                delegate?.didReceiveNotification(player: self.player, notification: .PlayerUnknownNotification)
                print("PlayerStatus Unknown")
                
            default:
                print("@unknown default")
            }
        }

        // handle keypath callback
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            
            if let isPlaybackLikelyToKeepUp = player.currentItem?.isPlaybackLikelyToKeepUp,
                player.timeControlStatus != .playing && !isPlaybackLikelyToKeepUp {
                delegate?.didReceiveNotification(player: player, notification: .PlayerBufferingStartNotification)
                //print("Playerstatus Buffer Start")
            } else {
                delegate?.didReceiveNotification(player: player, notification: .PlayerBufferingEndNotification)
                //print("PlayerStatus Buffer End")
            }
        }
    }
    
    func startPlayer() {
        
        guard let song = currentSong, let url = song.attributes?.previews?[0].url else { return }
        
        PlaySongManager.sharedInstance.playMusic(url: url)
        //self.player.play()
        
        delegate?.didReceiveNotification(player: self.player, notification: .PlayerDidToPlayNotification)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerNotification(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerNotification(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: self.player.currentItem)

    }
    
    func closePlayer() {
        self.pauseMusic()
        self.player.replaceCurrentItem(with: nil)
        self.removePlayerObserve()
        self.removeTimeObserve()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setRate(rate: Float) {
        self.player.setRate(rate, time: CMTime.invalid, atHostTime: CMTime.invalid)
    }
    
    func seekTo(_ progress: Double) {
        
        if self.player.currentItem?.seekableTimeRanges.count ?? 0 > 0 {
            
            guard let range = self.player.currentItem?.seekableTimeRanges.first?.timeRangeValue else { return }
            let position = CMTimeGetSeconds(range.start) + (CMTimeGetSeconds(range.duration) * progress)
            let pos = CMTimeMakeWithSeconds(position, preferredTimescale: range.duration.timescale)
            
            self.player.seek(to: pos, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
                self.timerInvalid = false
            }
        }
        
    }
    
    func seekToSecondOffset(to second: Int, is fwd: Bool) {
        
        if let currentItem = self.player.currentItem, self.player.currentItem?.seekableTimeRanges.count ?? 0 > 0 {
            
            guard let range = self.player.currentItem?.seekableTimeRanges.first?.timeRangeValue else { return }
            let currentTime = CMTimeGetSeconds(currentItem.currentTime())
            let position = fwd ? CMTimeMakeWithSeconds(currentTime + Double(second), preferredTimescale: range.duration.timescale) : CMTimeMakeWithSeconds(currentTime - Double(second), preferredTimescale: range.duration.timescale)
            
            self.player.seek(to: position, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
                self.timerInvalid = false
            }
        }
    }
    
    
    @objc func playerNotification(notification: Notification) {
        
        switch notification.name {
        case .AVPlayerItemDidPlayToEndTime:
            delegate?.didReceiveNotification(player: self.player, notification: .PlayerPlayFinishNotification)
            self.currentTime = 0
        case .AVPlayerItemFailedToPlayToEndTime:
            delegate?.didReceiveNotification(player: self.player, notification: .PlayerFailedNotification)
        default:
            break
        }
        
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                let percent = Float(event.positionTime) / Float(self.position.duration)
                print("change playback", percent)
                seekTo(Double(percent))
            }
            
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            print((current + maxCount - 1) % maxCount)
            delegate?.selectData(index: (current + maxCount - 1) % maxCount, isFromMiniPlayer: false)
            
            return.success
            
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            if event.timestamp != 0 {
                print((current + maxCount + 1) % maxCount)
                delegate?.selectData(index: (current + maxCount + 1) % maxCount, isFromMiniPlayer: false)
            }
            return.success
            
        }
    }
    
    func setupNowPlaying(title: String, image: UIImage?) {
        // Define Now Playing Info
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title

        if let image = image {
           
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                
            MPMediaItemArtwork(boundsSize: image.size) { _ in
        
                    return image
        
                }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playMusic(url: String) {
        
        print("Play")

        let musicURL = URL(string: url)
        
        playerItem = AVPlayerItem(url: musicURL!)

        player.replaceCurrentItem(with: playerItem)
        
        let time = CMTime(seconds: self.currentTime, preferredTimescale: 1)
        
        player.seek(to: time)
        
        player.play()

    }
    
    
    func pauseMusic() {

        player.pause()
    }
    
    deinit {
        
        delegate = nil
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification.Name {
    
    static let PlayerUnknownNotification = Notification.Name(rawValue: "UnknownNotification")
    
    static let PlayerReadyToPlayNotification = Notification.Name(rawValue: "ReadyToPlayNotification")
    
    static let PlayerDidToPlayNotification = Notification.Name(rawValue: "DidToPlayNotification")
    
    static let PlayerBufferingStartNotification = Notification.Name(rawValue: "BufferingStartNotification")
    
    static let PlayerBufferingEndNotification = Notification.Name(rawValue: "BufferingEndNotification")
    
    static let PlayerFailedNotification = Notification.Name(rawValue: "FailedNotification")
    
    static let PauseNotification = Notification.Name(rawValue: "PauseNotification")
    
    static let PlayerPlayFinishNotification = Notification.Name(rawValue: "PlayFinishNotification")
    
}
