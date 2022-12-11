//
//  SoulBarTestsThird.swift
//  SoulBarTests
//
//  Created by 陳建綸 on 2022/12/9.
//

import XCTest

@testable import SoulBar

final class SoulBarTestsThird: XCTestCase {
    
    var sut: MapManager!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        try super.setUpWithError()
        
        sut = MapManager.sharedInstance
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func testCoordinatesForAddress() {
        
        let location = "台北市信義區信義路五段7號"
        
        sut.coordinates(forAddress: location) { result in
            
            guard let result = result else {
                
                XCTAssertNotNil(result, "A non-nil coordinate should be returned")
                
                return
            }
            
            let lat = String(format: "%.2f", Double(result.latitude))
            
            let lon = String(format: "%.2f", Double(result.longitude))
            
            XCTAssertEqual(lat, "25.03", "The returned latitude should match the expected value")
            
            XCTAssertEqual(lon, "121.56", "The returned longitude should match the expected value")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
