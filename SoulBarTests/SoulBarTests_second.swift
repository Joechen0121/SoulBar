//
//  SoulBarTests_second.swift
//  SoulBarTests
//
//  Created by 陳建綸 on 2022/12/8.
//

import XCTest
import CoreMedia
@testable import SoulBar

final class SoulBarTestsSecond: XCTestCase {
    
    var sut: PlaySongManager!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        try super.setUpWithError()
        
        sut = PlaySongManager.sharedInstance

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        sut = nil
        
        try super.tearDownWithError()
    }

    func testPlayMusic() throws {
        
        let promise = expectation(description: "Music is Playing")
        
        let url =
        """
        https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/0b/bf/3f/0bbf3f9e-5e23-562b-b1cd-f09a8dadbe6e/mzaf_9056504767338380252.plus.aac.p.m4a
        """
        
        sut.playMusic(url: url)
    
        sut.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main) { [unowned self] time in
            
            XCTAssertNotNil(self.sut.player)
            
            XCTAssertTrue(self.sut.player.timeControlStatus == .playing)
            
            let totalSeconds = Int(time.value) / Int(time.timescale)
            
            if totalSeconds == 5 {
                
                promise.fulfill()
            }
            
        }
        
        wait(for: [promise], timeout: 500)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.

        }
    }

}
