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
    
    var position = PlayerPosition()
    
    let player = AVPlayer()
    
    weak var delegate: PlaySongDelegate?
    
    var current = 0
    
    var maxCount = 0
    
    var previousBackCount = 0
    
    var nextBackCount = 0
    
    var playerObserver: NSKeyValueObservation?
    
    var timeObserver: Any?
    
    var timerInvalid = false
    
    var queuePlayer: AVQueuePlayer?
    
    var playerItem: AVPlayerItem?
    
    var currentSong: SongsSearchInfo?
    
    var songs: [SongsSearchInfo]?
    
    var currentTime: Double = 0
    
    var isBackground = false
    
    var isBackgroundPausePlay = false

    func setupPlayer(with url: URL) {
        
        print(#function)
        
        let asset = AVURLAsset(url: url)
        
        let item = AVPlayerItem(asset: asset)
        
        self.currentTime = 0
        
        setupNowPlaying()

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
        
        guard self.timeObserver == nil else { return }
        
        self.timerInvalid = false
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main) { [weak self] _ in

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
                
                self.currentTime = CMTimeGetSeconds(self.player.currentTime())
                
                self.delegate?.didUpdatePosition(self.player, self.position)
            }
        }
    }
    
    func removePlayerObserve() {
        
        if let observer = self.playerObserver {
            
            if player.timeControlStatus == .paused {
    
                self.player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: nil)
                
                self.player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
            }
        }
    }
    
    func removeTimeObserve() {
        
        if let observer = timeObserver {
            
            if player.timeControlStatus == .paused {
    
                self.player.removeTimeObserver(observer)
                
                self.timeObserver = nil
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            
            let status: AVPlayerItem.Status
            
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            }
            else {
                status = .unknown
            }

            switch status {
            case .readyToPlay:
                delegate?.didReceiveNotification(player: self.player, notification: .PlayerReadyToPlayNotification)

                self.startPlayer()
                
                previousBackCount = 0
                nextBackCount = 0
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
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
            
            if player.timeControlStatus == .paused {
    
                if delegate != nil {
    
                    delegate?.didReceiveNotification(player: player, notification: .PlayerBufferingEndNotification)
                }
                else {
                    
                    if isBackgroundPausePlay == false {
                        
                        backgroundMode()
                    }
                    
                }
                
            } else {
                
                delegate?.didReceiveNotification(player: player, notification: .PlayerBufferingStartNotification)
                
                isBackground = false

            }
        }
    }
    
    func startPlayer() {
        guard let songs = PlaySongManager.sharedInstance.songs, !songs.isEmpty else { return }
        
        if PlaySongManager.sharedInstance.current >= songs.count {
            
            PlaySongManager.sharedInstance.current = 0
        }
        
        let song = songs[PlaySongManager.sharedInstance.current]
        
        guard let url = song.attributes?.previews?[0].url else { return }
        
        self.currentSong = song
        
        PlaySongManager.sharedInstance.playMusic(url: url)
        
        setupNowPlaying()
        
        delegate?.didReceiveNotification(player: self.player, notification: .PlayerDidToPlayNotification)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerNotification(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerNotification(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: self.player.currentItem)

    }
    
    func closePlayer() {
        self.pauseMusic()
        self.player.replaceCurrentItem(with: nil)
        self.currentTime = 0
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
        commandCenter.playCommand.addTarget { [weak self] _ in
            
            guard let self = self else { return .commandFailed }
            
            if self.player.rate == 0.0 {
                
                self.player.play()
                
                self.setupNowPlaying()
                
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
                
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            
            guard let self = self else { return .commandFailed }
            
            if self.player.rate == 1.0 {
                
                if self.delegate == nil {
                    
                    self.isBackgroundPausePlay = true
                }
                
                let time = CMTimeGetSeconds(self.player.currentTime())
                
                self.currentTime = time
                
                self.player.pause()
                
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
                
                return .success

            }
            return .commandFailed
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
    
            guard let self = self else { return .commandFailed }
            
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                
                let percent = Float(event.positionTime) / Float(self.position.duration)
                
                print("change playback", percent)
                
                self.seekTo(Double(percent))
            }
            
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            
            guard let self = self else { return .commandFailed }
            
            if self.delegate != nil {
                
                guard self.previousBackCount == 0 else { return .commandFailed }
                
                self.previousBackCount += 1
    
                self.closePlayer()
                
                self.delegate!.selectData(index: (self.current + self.maxCount - 1) % self.maxCount, isFromMiniPlayer: false)

            }
            else {
                
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerPrevious"), object: nil)
                
            }
            
            return.success
            
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            
            guard let self = self else { return .commandFailed }
            
            if self.delegate != nil {
                
                guard self.nextBackCount == 0 else { return .commandFailed }
                
                self.nextBackCount += 1
                
                self.closePlayer()
                
                self.delegate!.selectData(index: (self.current + self.maxCount + 1) % self.maxCount, isFromMiniPlayer: false)
            }
            else {
             
                NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerNext"), object: nil)
            }
            

            return.success
            
        }
    }
    
    func setupNowPlaying() {

        var nowPlayingInfo = [String : Any]()
        
        guard let song = PlaySongManager.sharedInstance.currentSong else {
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = nil
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 0
            
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0

            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            
            return
            
        }
        
        if let artworkURL = song.attributes?.artwork?.url, let width = song.attributes?.artwork?.width, let height = song.attributes?.artwork?.height {
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = PlaySongManager.sharedInstance.currentSong?.attributes?.name
            
            let pictureURL = MusicManager.sharedInstance.fetchPicture(url: artworkURL, width: String(width), height: String(height))
            
            if let data = try? Data(contentsOf: URL(string: pictureURL)!) {
                let image: UIImage = UIImage(data: data)!
                
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
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

        guard let musicURL = URL(string: url) else { return }
            
        playerItem = AVPlayerItem(url: musicURL)
    
        player.replaceCurrentItem(with: playerItem)

        self.delegate?.didUpdatePosition(self.player, self.position)
        
        let time = CMTime(seconds: self.currentTime, preferredTimescale: 1000)

        player.seek(to: time)
        
        player.play()

    }
    
    
    func pauseMusic() {
        
        isBackground = true

        player.pause()
    }
    
    func backgroundMode() {
        
        print(#function)
        
        guard isBackground == false else { return }

        isBackground = true
        
        if self.current + 1 < self.maxCount {

            pauseMusic()
            
            currentTime = 0

            self.current += 1

            guard let songs = songs, let url = songs[current].attributes?.previews?[0].url else {
                return
            }
            
            startPlayer()
            
        }
        else {
            
            pauseMusic()
            
            self.current = maxCount
        }
        
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerView"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("didUpdateMiniPlayerButton"), object: nil)
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
