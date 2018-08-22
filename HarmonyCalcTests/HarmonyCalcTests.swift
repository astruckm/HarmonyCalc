//
//  HarmonyCalcTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 8/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class HarmonyCalcTests: XCTestCase {
    
    var harmonyModel = HarmonyModel(maxNotesInCollection: 6)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after thUse of unresolved identifier 'HarmonyModel'e invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNontonal() {
        let pitchCollection: [PitchClass] = [.c, .gSharp, .d]
        XCTAssert(harmonyModel.normalForm(of: pitchCollection) == [.gSharp, .c, .d])
        XCTAssert(harmonyModel.primeForm(of: pitchCollection) == [0,2,6])
        XCTAssert(harmonyModel.getChordIdentity(of: pitchCollection) == nil)
        let keys = pitchCollection.map{($0, Octave.zero)}
        XCTAssert(harmonyModel.getChordInversion(of: keys) == nil)
    }
    
    func testTonal() {
        let pitchCollection: [PitchClass] = [.fSharp, .dSharp, .aSharp, .cSharp]
        XCTAssert(harmonyModel.normalForm(of: pitchCollection) == [.aSharp, .cSharp, .dSharp, .fSharp])
        XCTAssert(harmonyModel.primeForm(of: pitchCollection) == [0,3,5,8])
        XCTAssert(harmonyModel.getChordIdentity(of: pitchCollection)! == (.dSharp, .minorSeventh))
        let keys = pitchCollection.map{($0, Octave.zero)}
        XCTAssert(harmonyModel.getChordInversion(of: keys)! == "3rd")
    }
    
    
}
