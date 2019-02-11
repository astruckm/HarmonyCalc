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
    //Test helper func--lowest abstraction level
    func testPairIsSpelledSuboptimally() {
        guard let cSharp = Note(pitchClass: .cSharp, noteLetter: .c, octave: nil) else { return }
        guard let dFlat = Note(pitchClass: .cSharp, noteLetter: .d, octave: nil) else { return }
        guard let eNatural = Note(pitchClass: .e, noteLetter: .e, octave: nil) else { return }
        guard let fNatural = Note(pitchClass: .f, noteLetter: .f, octave: nil) else { return }
        guard let fSharp = Note(pitchClass: .fSharp, noteLetter: .f, octave: nil) else { return }
        guard let gSharp = Note(pitchClass: .gSharp, noteLetter: .g, octave: nil) else { return }
        guard let aFlat = Note(pitchClass: .gSharp, noteLetter: .a, octave: nil) else { return }

        XCTAssert(!bestHarmonicSpelling.pairIsSpelledSuboptimally((eNatural, fSharp)))
        XCTAssert(bestHarmonicSpelling.pairIsSpelledSuboptimally((eNatural, dFlat)))
        XCTAssert(bestHarmonicSpelling.pairIsSpelledSuboptimally((cSharp, dFlat)))
        XCTAssert(bestHarmonicSpelling.pairIsSpelledSuboptimally((fNatural, gSharp)))
        XCTAssert(!bestHarmonicSpelling.pairIsSpelledSuboptimally((dFlat, aFlat)))
    }
    
    //Test helper func--mid-level of abstraction
    func testNumSuboptimalSpellings() {
        guard let cSharp = Note(pitchClass: .cSharp, noteLetter: .c, octave: nil) else { return }
        guard let dFlat = Note(pitchClass: .cSharp, noteLetter: .d, octave: nil) else { return }
        guard let eNatural = Note(pitchClass: .e, noteLetter: .e, octave: nil) else { return }
        guard let fNatural = Note(pitchClass: .f, noteLetter: .f, octave: nil) else { return }
        guard let fSharp = Note(pitchClass: .fSharp, noteLetter: .f, octave: nil) else { return }
        guard let gSharp = Note(pitchClass: .gSharp, noteLetter: .g, octave: nil) else { return }
        guard let aFlat = Note(pitchClass: .gSharp, noteLetter: .a, octave: nil) else { return }
        
        let wellSpelledNotes: [Note] = [cSharp, eNatural, fSharp]
        let shouldBeSharpsNotes: [Note] = [dFlat, eNatural, aFlat]
        let shouldBeFlatsNotes: [Note] = [cSharp, fNatural, gSharp]
        
        XCTAssert(bestHarmonicSpelling.pairsWithSuboptimalSpellings(among: wellSpelledNotes).isEmpty)
        XCTAssert(bestHarmonicSpelling.pairsWithSuboptimalSpellings(among: shouldBeSharpsNotes).count == 2)
        XCTAssert(bestHarmonicSpelling.pairsWithSuboptimalSpellings(among: shouldBeFlatsNotes).count == 2)
    }
    
    
    func testCorrectAccidentalTypeTriads() {
        let shouldBeSharpsPC: [PitchClass] = [.cSharp, .e, .gSharp]
        let shouldBeFlatsPC: [PitchClass] = [.cSharp, .f, .gSharp]
        
        XCTAssert(bestHarmonicSpelling.collectionShouldUseSharps(shouldBeSharpsPC))
        XCTAssert(!(bestHarmonicSpelling.collectionShouldUseSharps(shouldBeFlatsPC)))
    }
    
    func testCorrectAccidentalTypeAtonal() {
        let atonalPC: [PitchClass] = [.e, .f, .aSharp]
        XCTAssert(!bestHarmonicSpelling.collectionShouldUseSharps(atonalPC))
    }
    
    //It should just default to sharps if equal number of suboptimal spellings
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
