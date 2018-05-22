//
//  Chord_ConnectionsTests.swift
//  Chord ConnectionsTests
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import XCTest
@testable import MusicWeb

class MusicWebTests: XCTestCase {
    
    var harmonyModelUnderTest: HarmonyModel!
    var pitchCollectionsToTest: [PitchClass] = []
    
    override func setUp() {
        super.setUp()
        harmonyModelUnderTest = HarmonyModel()
    }
    
    override func tearDown() {
        harmonyModelUnderTest = nil
        pitchCollectionsToTest = []
        super.tearDown()
    }
    
    //TODO: test various combinations of pitch collections once there is omnibus pitch collection function
    //2-note, 3-note, etc.
    //tonal, non-tonal; different inversions of same collection
    
    func testNormalFormCalculatedCorrectly() {
        //Given
        pitchCollectionsToTest = [.c, .gSharp, .d]
        //When
        let calculatedValue = harmonyModelUnderTest.normalForm(of: pitchCollectionsToTest)
        //Then
        XCTAssertEqual(calculatedValue, [.gSharp, .c, .d], "Score computed from guess is wrong")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
