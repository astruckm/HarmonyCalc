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
    let conversions = Conversions()
    
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
    

}

//Test enharmonic spelling detection
extension HarmonyCalcTests {
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

//Test harmony types
extension HarmonyCalcTests {
    func testIntervalFromQualityAndSize() {
        let diminishedFourth = Interval(quality: .diminished, size: .fourth)
        let minorSeventh = Interval(quality: .minor, size: .seventh)
        let undefinedInterval = Interval(quality: .perfect, size: .second)
        
        XCTAssert(diminishedFourth?.pitchIntervalClass == .four)
        XCTAssert(minorSeventh?.pitchIntervalClass == .ten)
        XCTAssert(undefinedInterval == nil)
    }
    
    func testIntervalFromPIClassAndSize() {
        let tritone1 = Interval(intervalClass: .six, size: .fifth)
        let tritone2 = Interval(intervalClass: .six, size: .fourth)
        let undefinedInterval = Interval(intervalClass: .seven, size: .fourth)
        
        XCTAssert(tritone1?.quality == .diminished)
        XCTAssert(tritone2?.quality == .augmented)
        XCTAssert(undefinedInterval == nil)
    }
}

//Test conversions between types
extension HarmonyCalcTests {
    func testPitchIntervalClassBetweenNotes() {
        
    }
    
    func testIntervalDiatonicSizeBetweenNotes() {
        
    }
}
