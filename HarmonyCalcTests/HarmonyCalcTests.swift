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
    var harmonyModel = HarmonyModel(maxNotesInCollection: 88)
    
    enum PianoKeyCollections {
        // Tonal
        static let dMaj: [PianoKey] = [(.d, .zero), (.a, .zero), (.fSharp, .one)] // root position
        static let fMin: [PianoKey] = [(.gSharp, .zero), (.f, .one), (.c, .one)] // 2nd inversion
        static let cSharpDim: [PianoKey] = [(.cSharp, .zero), (.g, .zero), (.e, .one)] // root position
        static let cAug: [PianoKey] = [(.e, .zero), (.c, .one), (.gSharp, .one)] // 1st inversion
        static let esus4: [PianoKey] = [(.e, .zero), (.a, .zero), (.b, .zero)] // root position
        
        static let fSharpDominant7: [PianoKey] = [(.fSharp, .zero), (.cSharp, .one), (.aSharp, .one), (.e, .one)] // root position
        static let eMin7: [PianoKey] = [(.e, .zero), (.d, .one), (.g, .one), (.b, .one)] // root position
        static let eMaj7: [PianoKey] = [(.e, .zero), (.dSharp, .zero), (.b, .one), (.gSharp, .zero)] // 3rd inversion
        static let gSharpFullyDim7: [PianoKey] = [(.gSharp, .one), (.b, .one), (.f, .one), (.d, .zero)] // 1st inversion (has to actually be b natural fully dim 7 due to no scale / spelling context)
        static let bHalfDim7: [PianoKey] = [(.a, .zero), (.b, .zero), (.f, .one), (.d, .one)] // 3rd inversion
        static let cAug7: [PianoKey] = [(.c, .one), (.e, .zero), (.gSharp, .one), (.aSharp, .one)] // 1st inversion
        static let dAugMaj7: [PianoKey] = [(.d, .one), (.fSharp, .zero), (.cSharp, .one), (.aSharp, .zero)] // 1st inversion
        
        static let fDominant9: [PianoKey] = [(.dSharp, .zero), (.f, .zero), (.g, .zero), (.a, .zero), (.c, .one)] // 3rd inversion
        static let gMaj9: [PianoKey] = [(.fSharp, .zero), (.a, .zero), (.g, .one), (.b, .one), (.d, .one)] // 3rd inversion
        static let aMin9: [PianoKey] = [(.e, .one), (.c, .one), (.g, .one), (.a, .zero), (.b, .one)] // root position
        static let g7Flat9: [PianoKey] = [(.b, .one), (.g, .one), (.d, .zero), (.gSharp, .one), (.f, .one)] // 2nd inversion
        static let b7Sharp9: [PianoKey] = [(.b, .zero), (.d, .zero), (.dSharp, .one), (.fSharp, .one), (.a, .one)] // 4th inversion
        
        static let eFlatDominant11: [PianoKey] = [(.dSharp, .one), (.cSharp, .one), (.g, .one), (.aSharp, .one), (.f, .one), (.gSharp, .zero)] // 5th inversion
        static let cMaj11: [PianoKey] = [(.e, .zero), (.c, .zero), (.b, .zero), (.g, .zero), (.f, .zero), (.d, .zero)] // root position
        static let eMin11: [PianoKey] = [(.e, .one), (.b, .one), (.g, .zero), (.d, .one), (.f, .zero), (.a, .zero)] // 4th inversion
        static let a7Sharp11: [PianoKey] = [(.e, .zero), (.cSharp, .one), (.g, .zero), (.a, .zero), (.dSharp, .zero), (.b, .one)] // 2nd inversion
        
        static let dDominant13: [PianoKey] = [(.e, .one), (.cSharp, .one), (.g, .one), (.a, .zero), (.d, .one), (.fSharp, .one), (.b, .zero)] // 2nd inversion
        static let d7Flat13: [PianoKey] = [(.e, .one), (.aSharp, .zero), (.cSharp, .one), (.g, .one), (.d, .one), (.a, .one), (.fSharp, .one)] // 6th inversion
        
        // Non-tonal
        static let zeroTwoSix: [PianoKey] = [(.d, .one), (.c, .zero), (.gSharp, .one)] // [0, 2, 6]
        static let allIntervalTetrachord: [PianoKey] = [(.g, .one), (.cSharp, .one), (.gSharp, .zero), (.b, .one)] // [0, 1, 4, 6]
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNontonal() {
        let pitchCollection1: [PitchClass] = PianoKeyCollections.zeroTwoSix.map { $0.pitchClass }
        let normalFormPC: [PitchClass] = harmonyModel.normalForm(of: pitchCollection1)
        
        XCTAssert(normalFormPC == [.gSharp, .c, .d])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormPC) == [0,2,6])
        XCTAssert(harmonyModel.getChordIdentity(of: pitchCollection1) == nil)
        let keys1 = pitchCollection1.map { ($0, Octave.zero) }
        XCTAssert(harmonyModel.getChordInversion(of: keys1) == nil)
    }
    
    func testTriads() {
        let majorTransforms = performCollectionTransforms(PianoKeyCollections.dMaj)
        XCTAssert(majorTransforms.normalForm == [.d, .fSharp, .a])
        XCTAssert(majorTransforms.primeForm == [0, 3, 7])
        XCTAssert(majorTransforms.identity ?? (.c, .major) == (.d, .major))
        XCTAssert(majorTransforms.inversion == "Root")

        let minorTransforms = performCollectionTransforms(PianoKeyCollections.fMin)
        XCTAssert(minorTransforms.normalForm == [.f, .gSharp, .c])
        XCTAssert(minorTransforms.primeForm == [0, 3, 7])
        XCTAssert(minorTransforms.identity ?? (.c, .major) == (.f, .minor))
        XCTAssert(minorTransforms.inversion == "1st")

        let dimTransforms = performCollectionTransforms(PianoKeyCollections.cSharpDim)
        XCTAssert(dimTransforms.normalForm == [.cSharp, .e, .g])
        XCTAssert(dimTransforms.primeForm == [0, 3, 6])
        XCTAssert(dimTransforms.identity ?? (.c, .major) == (.cSharp, .diminished))
        XCTAssert(dimTransforms.inversion == "Root")
        
        let augTransforms = performCollectionTransforms(PianoKeyCollections.cAug)
        XCTAssert(augTransforms.normalForm == [.c, .e, .gSharp])
        XCTAssert(augTransforms.primeForm == [0, 4, 8])
        XCTAssert(augTransforms.identity ?? (.c, .major) == (.c, .augmented))
        XCTAssert(augTransforms.inversion == "1st")
        
        let sus4Transforms = performCollectionTransforms(PianoKeyCollections.esus4)
        XCTAssert(sus4Transforms.normalForm == [.a, .b, .e])
        XCTAssert(sus4Transforms.primeForm == [0, 2, 7])
        XCTAssert(sus4Transforms.identity ?? (.c, .major) == (.e, .suspended))
        XCTAssert(sus4Transforms.inversion == "Root")
    }
    
    func testSevenChords() {
        let dom7Transforms = performCollectionTransforms(PianoKeyCollections.fSharpDominant7)
        XCTAssert(dom7Transforms.normalForm == [.aSharp, .cSharp, .e, .fSharp])
        XCTAssert(dom7Transforms.primeForm == [0, 2, 5, 8])
        XCTAssert(dom7Transforms.identity ?? (.c, .major) == (.fSharp, .dominantSeven))
        XCTAssert(dom7Transforms.inversion == "Root")
        
        let maj7Transforms = performCollectionTransforms(PianoKeyCollections.eMaj7)
        XCTAssert(maj7Transforms.normalForm == [.dSharp, .e, .gSharp, .b])
        XCTAssert(maj7Transforms.primeForm == [0, 1, 5, 8])
        XCTAssert(maj7Transforms.identity ?? (.c, .major) == (.e, .majorSeven))
        XCTAssert(maj7Transforms.inversion == "3rd")

        let min7Transforms = performCollectionTransforms(PianoKeyCollections.eMin7)
        XCTAssert(min7Transforms.normalForm == [.b, .d, .e, .g])
        XCTAssert(min7Transforms.primeForm == [0, 3, 5, 8])
        XCTAssert(min7Transforms.identity ?? (.c, .major) == (.e, .minorSeven))
        XCTAssert(min7Transforms.inversion == "Root")
        
        let fullyDim7Transforms = performCollectionTransforms(PianoKeyCollections.gSharpFullyDim7)
        XCTAssert(fullyDim7Transforms.normalForm == [.b, .d, .f, .gSharp])
        XCTAssert(fullyDim7Transforms.primeForm == [0, 3, 6, 9])
        XCTAssert(fullyDim7Transforms.identity ?? (.c, .major) == (.b, .diminishedSeven))
        XCTAssert(fullyDim7Transforms.inversion == "3rd")

        let halfDim7Transforms = performCollectionTransforms(PianoKeyCollections.bHalfDim7)
        XCTAssert(halfDim7Transforms.normalForm == [.a, .b, .d, .f])
        XCTAssert(halfDim7Transforms.primeForm == [0, 2, 5, 8])
        XCTAssert(halfDim7Transforms.identity ?? (.c, .major) == (.b, .halfDiminishedSeven))
        XCTAssert(halfDim7Transforms.inversion == "3rd")
        
        let aug7Transforms = performCollectionTransforms(PianoKeyCollections.cAug7)
        XCTAssert(aug7Transforms.normalForm == [.gSharp, .aSharp, .c, .e])
        XCTAssert(aug7Transforms.primeForm == [0, 2, 4, 8])
        XCTAssert(aug7Transforms.identity ?? (.c, .major) == (.c, .augmentedSeven))
        XCTAssert(aug7Transforms.inversion == "1st")
        
        let augMaj7Transforms = performCollectionTransforms(PianoKeyCollections.dAugMaj7)
        XCTAssert(augMaj7Transforms.normalForm == [.aSharp, .cSharp, .d, .fSharp])
        XCTAssert(augMaj7Transforms.primeForm == [0, 3, 4, 8])
        XCTAssert(augMaj7Transforms.identity ?? (.c, .major) == (.d, .augmentedMajorSeven))
        XCTAssert(augMaj7Transforms.inversion == "1st")
    }
    
    func testNineChords() {
        let dom9Transforms = performCollectionTransforms(PianoKeyCollections.fDominant9)
        XCTAssert(dom9Transforms.normalForm == [.dSharp, .f, .g, .a, .c])
        XCTAssert(dom9Transforms.primeForm == [0, 2, 4, 6, 9])
        XCTAssert(dom9Transforms.identity ?? (.c, .major) == (.f, .dominantNine))
        XCTAssert(dom9Transforms.inversion == "4th")
        
        let maj9Transforms = performCollectionTransforms(PianoKeyCollections.gMaj9)
        XCTAssert(maj9Transforms.normalForm == [.fSharp, .g, .a, .b, .d])
        XCTAssert(maj9Transforms.primeForm == [0, 1, 3, 5, 8])
        XCTAssert(maj9Transforms.identity ?? (.c, .major) == (.g, .majorNine))
        XCTAssert(maj9Transforms.inversion == "3rd")
        
        let min9Transforms = performCollectionTransforms(PianoKeyCollections.aMin9)
        XCTAssert(min9Transforms.normalForm == [.e, .g, .a, .b, .c])
        XCTAssert(min9Transforms.primeForm == [0, 1, 3, 5, 8])
        XCTAssert(min9Transforms.identity ?? (.c, .major) == (.a, .minorNine))
        XCTAssert(min9Transforms.inversion == "Root")
        
        let flat9Transforms = performCollectionTransforms(PianoKeyCollections.g7Flat9)
        XCTAssert(flat9Transforms.normalForm == [.f, .g, .gSharp, .b, .d])
        XCTAssert(flat9Transforms.primeForm == [0, 2, 3, 6, 9])
        XCTAssert(flat9Transforms.identity ?? (.c, .major) == (.g, .flatNine))
        XCTAssert(flat9Transforms.inversion == "1st")
        
        let sharp9Transforms = performCollectionTransforms(PianoKeyCollections.b7Sharp9)
        XCTAssert(sharp9Transforms.normalForm == [.a, .b, .d, .dSharp, .fSharp])
        XCTAssert(sharp9Transforms.primeForm == [0, 2, 5, 6, 9])
        XCTAssert(sharp9Transforms.identity ?? (.c, .major) == (.b, .sharpNine))
        XCTAssert(sharp9Transforms.inversion == "4th")
    }
    
    func testElevenChords() {
        let dom11Transforms = performCollectionTransforms(PianoKeyCollections.eFlatDominant11)
        XCTAssert(dom11Transforms.normalForm == [.cSharp, .dSharp, .f, .g, .gSharp, .aSharp])
        XCTAssert(dom11Transforms.primeForm == [0, 2, 3, 5, 7, 9])
        XCTAssert(dom11Transforms.identity ?? (.c, .major) == (.dSharp, .eleven))
        XCTAssert(dom11Transforms.inversion == "5th")
        
        let maj11Transforms = performCollectionTransforms(PianoKeyCollections.cMaj11)
        XCTAssert(maj11Transforms.normalForm == [.b, .c, .d, .e, .f, .g])
        XCTAssert(maj11Transforms.primeForm == [0, 1, 3, 5, 6, 8])
        XCTAssert(maj11Transforms.identity ?? (.c, .major) == (.c, .majorEleven))
        XCTAssert(maj11Transforms.inversion == "Root")
        
        let min11Transforms = performCollectionTransforms(PianoKeyCollections.eMin11)
        XCTAssert(min11Transforms.normalForm == [.d, .e, .fSharp, .g, .a, .b])
        XCTAssert(min11Transforms.primeForm == [0, 2, 4, 5, 7, 9])
        XCTAssert(min11Transforms.identity ?? (.c, .major) == (.e, .minorEleven))
        XCTAssert(min11Transforms.inversion == "4th")
        
        let sharp11Transforms = performCollectionTransforms(PianoKeyCollections.a7Sharp11)
        XCTAssert(sharp11Transforms.normalForm == [.g, .a, .b, .cSharp, .dSharp, .e])
        XCTAssert(sharp11Transforms.primeForm == [0, 1, 3, 5, 7, 9])
        XCTAssert(sharp11Transforms.identity ?? (.c, .major) == (.a, .sharpEleven))
        XCTAssert(sharp11Transforms.inversion == "2nd")
    }
    
    func testThirteenChords() {
        let dom13Transforms = performCollectionTransforms(PianoKeyCollections.aDominant13)
        XCTAssert(dom13Transforms.normalForm == [.cSharp, .d, .e, .fSharp, .g, .a, .b])
        XCTAssert(dom13Transforms.primeForm == [0, 1, 3, 5, 6, 8, 10])
        XCTAssert(dom13Transforms.identity ?? (.c, .major) == (.a, .thirteen))
        XCTAssert(dom13Transforms.inversion == "2nd")
    }
        
    private func performCollectionTransforms(_ keys: [PianoKey]) -> (normalForm: [PitchClass],
                                                                                  primeForm: [Int],
                                                                                  identity: (root: PitchClass, chordQuality: TonalChordType)?,
                                                                                  inversion: String?) {
        let pitchCollection = keys.map { $0.pitchClass }
        let normalForm = harmonyModel.normalForm(of: pitchCollection)
        let primeForm = harmonyModel.primeForm(ofCollectionInNormalForm: normalForm)
        let chordIdentity = harmonyModel.getChordIdentity(of: pitchCollection)
        let inversion = harmonyModel.getChordInversion(of: keys)
        return (normalForm: normalForm, primeForm: primeForm, identity: chordIdentity, inversion: inversion)
    }
    
}
