//
//  SoulBarTests.swift
//  SoulBarTests
//
//  Created by 陳建綸 on 2022/12/8.
//

import XCTest
@testable import SoulBar

final class SoulBarTests: XCTestCase {
    
    var sut: SearchDetailsViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        try super.setUpWithError()
        
        sut = SearchDetailsViewController()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        sut = nil
        
        try super.tearDownWithError()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            
            /*
             * 0: All type
             * 1: Artists
             * 2: Songs
             * 3: Albums
             */
            sut.fetchMusicData(buttonTag: 1, text: "joji")
        }
    }

}
