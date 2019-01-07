//
//  HarmonyCalcTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 12/31/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class HarmonyCalcTests: XCTestCase {
    
    //Mocks
    var harmonyModel = HarmonyModel(maxNotesInCollection: 6)
    let bestHarmonicSpelling = BestEnharmonicSpelling()
    
    //Items under test
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNontonal() {
        let pitchCollection: [PitchClass] = [.c, .gSharp, .d]
        let normalFormPC: [PitchClass] = harmonyModel.normalForm(of: pitchCollection)
        
        XCTAssert(normalFormPC == [.gSharp, .c, .d])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormPC) == [0,2,6])
        XCTAssert(harmonyModel.getChordIdentity(of: pitchCollection) == nil)
        let keys = pitchCollection.map{($0, Octave.zero)}
        XCTAssert(harmonyModel.getChordInversion(of: keys) == nil)
    }
    
    func testTonal() {
        let pitchCollection: [PitchClass] = [.fSharp, .dSharp, .aSharp, .cSharp]
        let normalFormPC: [PitchClass] = harmonyModel.normalForm(of: pitchCollection)
        
        XCTAssert(normalFormPC == [.aSharp, .cSharp, .dSharp, .fSharp])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormPC) == [0,3,5,8])
        XCTAssert(harmonyModel.getChordIdentity(of: pitchCollection)! == (.dSharp, .minorSeventh))
        let keys = pitchCollection.map{($0, Octave.zero)}
        XCTAssert(harmonyModel.getChordInversion(of: keys)! == "3rd")
    }
    
    func testCorrectAccidentalTypeTriads() {
        let shouldBeSharpsPC: [PitchClass] = [.cSharp, .e, .gSharp]
        let shouldBeFlatsPC: [PitchClass] = [.cSharp, .f, .gSharp]
        
        XCTAssert(bestHarmonicSpelling.collectionShouldUseSharps(shouldBeSharpsPC))
        XCTAssert(!(bestHarmonicSpelling.collectionShouldUseSharps(shouldBeFlatsPC)))
    }
    
    func testCorrectAccidentalTypeAtonal() {
        let atonalPC: [PitchClass] = [.e, .f, .gSharp]
        XCTAssert(!bestHarmonicSpelling.collectionShouldUseSharps(atonalPC))
    }
    
    func testCorrectAccidentalTypeAmbiguous() {
        let ambiguouslySpelledPC: [PitchClass] = [.cSharp, .f, .g, .b]
        XCTAssert(bestHarmonicSpelling.collectionShouldUseSharps(ambiguouslySpelledPC))
    }


}
