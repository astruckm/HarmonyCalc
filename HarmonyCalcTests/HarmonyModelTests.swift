//
//  HarmonyModelTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 12/31/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class HarmonyModelTests: XCTestCase {
    //Mocks
    let harmonyModel = HarmonyModel(maxNotesInCollection: 88)
    
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
        static let eMin11: [PianoKey] = [(.e, .one), (.b, .one), (.g, .zero), (.d, .one), (.fSharp, .zero), (.a, .zero)] // 4th inversion
        static let a7Sharp11: [PianoKey] = [(.e, .zero), (.cSharp, .one), (.g, .zero), (.a, .zero), (.dSharp, .zero), (.b, .one)] // 5th inversion
        
        static let aDominant13: [PianoKey] = [(.e, .zero), (.cSharp, .one), (.g, .one), (.a, .zero), (.d, .one), (.fSharp, .one), (.b, .zero)] // 2nd inversion
        
        // Non-tonal
        static let zeroTwoSix: [PianoKey] = [(.d, .one), (.c, .zero), (.gSharp, .one)] // [0, 2, 6]
        static let allIntervalTetrachord: [PianoKey] = [(.g, .one), (.cSharp, .one), (.gSharp, .zero), (.b, .one)] // [0, 1, 4, 6]
    }

    func testNontonal() {
        let pitchCollection1: [PitchClass] = PianoKeyCollections.zeroTwoSix.map { $0.pitchClass }
        let normalFormPC: [PitchClass] = harmonyModel.normalForm(of: pitchCollection1)
        
        XCTAssert(normalFormPC == [.gSharp, .c, .d])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormPC) == [0,2,6])
        assertChord(harmonyModel.chord(from: PianoKeyCollections.zeroTwoSix), .gSharp, "(♭5)", "1st")
        XCTAssertNil(harmonyModel.chord(from: PianoKeyCollections.allIntervalTetrachord))
    }
    
    func testTriads() {
        let majorTransforms = performCollectionTransforms(PianoKeyCollections.dMaj)
        XCTAssert(majorTransforms.normalForm == [.d, .fSharp, .a])
        XCTAssert(majorTransforms.primeForm == [0, 3, 7])
        assertChord(majorTransforms.chord, .d, "", "Root")

        let minorTransforms = performCollectionTransforms(PianoKeyCollections.fMin)
        XCTAssert(minorTransforms.normalForm == [.f, .gSharp, .c])
        XCTAssert(minorTransforms.primeForm == [0, 3, 7])
        assertChord(minorTransforms.chord, .f, "m", "1st")

        let dimTransforms = performCollectionTransforms(PianoKeyCollections.cSharpDim)
        XCTAssert(dimTransforms.normalForm == [.cSharp, .e, .g])
        XCTAssert(dimTransforms.primeForm == [0, 3, 6])
        assertChord(dimTransforms.chord, .cSharp, "°", "Root")
        
        let augTransforms = performCollectionTransforms(PianoKeyCollections.cAug)
        XCTAssert(augTransforms.normalForm == [.c, .e, .gSharp])
        XCTAssert(augTransforms.primeForm == [0, 4, 8])
        assertChord(augTransforms.chord, .e, "⁺", "Root")
        
        let sus4Transforms = performCollectionTransforms(PianoKeyCollections.esus4)
        XCTAssert(sus4Transforms.normalForm == [.a, .b, .e])
        XCTAssert(sus4Transforms.primeForm == [0, 2, 7])
        assertChord(sus4Transforms.chord, .e, "sus4", "Root")
    }
    
    func testSevenChords() {
        let dom7Transforms = performCollectionTransforms(PianoKeyCollections.fSharpDominant7)
        XCTAssert(dom7Transforms.normalForm == [.aSharp, .cSharp, .e, .fSharp])
        XCTAssert(dom7Transforms.primeForm == [0, 2, 5, 8])
        assertChord(dom7Transforms.chord, .fSharp, "7", "Root")
        
        let maj7Transforms = performCollectionTransforms(PianoKeyCollections.eMaj7)
        XCTAssert(maj7Transforms.normalForm == [.dSharp, .e, .gSharp, .b])
        XCTAssert(maj7Transforms.primeForm == [0, 1, 5, 8])
        assertChord(maj7Transforms.chord, .e, "maj7", "3rd")

        let min7Transforms = performCollectionTransforms(PianoKeyCollections.eMin7)
        XCTAssert(min7Transforms.normalForm == [.b, .d, .e, .g])
        XCTAssert(min7Transforms.primeForm == [0, 3, 5, 8])
        assertChord(min7Transforms.chord, .e, "m7", "Root")
        
        let fullyDim7Transforms = performCollectionTransforms(PianoKeyCollections.gSharpFullyDim7)
        XCTAssert(fullyDim7Transforms.normalForm == [.b, .d, .f, .gSharp])
        XCTAssert(fullyDim7Transforms.primeForm == [0, 3, 6, 9])
        assertChord(fullyDim7Transforms.chord, .d, "°7", "Root")

        let halfDim7Transforms = performCollectionTransforms(PianoKeyCollections.bHalfDim7)
        XCTAssert(halfDim7Transforms.normalForm == [.a, .b, .d, .f])
        XCTAssert(halfDim7Transforms.primeForm == [0, 2, 5, 8])
        assertChord(halfDim7Transforms.chord, .b, "ø7", "3rd")
        
        let aug7Transforms = performCollectionTransforms(PianoKeyCollections.cAug7)
        XCTAssert(aug7Transforms.normalForm == [.gSharp, .aSharp, .c, .e])
        XCTAssert(aug7Transforms.primeForm == [0, 2, 4, 8])
        assertChord(aug7Transforms.chord, .c, "7(♯5)", "1st")
        
        let augMaj7Transforms = performCollectionTransforms(PianoKeyCollections.dAugMaj7)
        XCTAssert(augMaj7Transforms.normalForm == [.aSharp, .cSharp, .d, .fSharp])
        XCTAssert(augMaj7Transforms.primeForm == [0, 3, 4, 8])
        assertChord(augMaj7Transforms.chord, .d, "maj7(♯5)", "1st")
    }
    
    func testNineChords() {
        let dom9Transforms = performCollectionTransforms(PianoKeyCollections.fDominant9)
        XCTAssert(dom9Transforms.normalForm == [.dSharp, .f, .g, .a, .c])
        XCTAssert(dom9Transforms.primeForm == [0, 2, 4, 6, 9])
        assertChord(dom9Transforms.chord, .f, "9", "3rd")
        
        let maj9Transforms = performCollectionTransforms(PianoKeyCollections.gMaj9)
        XCTAssert(maj9Transforms.normalForm == [.fSharp, .g, .a, .b, .d])
        XCTAssert(maj9Transforms.primeForm == [0, 1, 3, 5, 8])
        assertChord(maj9Transforms.chord, .g, "maj9", "3rd")
        
        let min9Transforms = performCollectionTransforms(PianoKeyCollections.aMin9)
        XCTAssert(min9Transforms.normalForm == [.e, .g, .a, .b, .c])
        XCTAssert(min9Transforms.primeForm == [0, 1, 3, 5, 8])
        assertChord(min9Transforms.chord, .a, "m9", "Root")
        
        let flat9Transforms = performCollectionTransforms(PianoKeyCollections.g7Flat9)
        XCTAssert(flat9Transforms.normalForm == [.f, .g, .gSharp, .b, .d])
        XCTAssert(flat9Transforms.primeForm == [0, 2, 3, 6, 9])
        assertChord(flat9Transforms.chord, .f, "°9", "3rd")
        
        let sharp9Transforms = performCollectionTransforms(PianoKeyCollections.b7Sharp9)
        XCTAssert(sharp9Transforms.normalForm == [.a, .b, .d, .dSharp, .fSharp])
        XCTAssert(sharp9Transforms.primeForm == [0, 2, 5, 6, 9])
        assertChord(sharp9Transforms.chord, .b, "7(♯9)", "4th")
    }
    
    func testElevenChords() {
        let dom11Transforms = performCollectionTransforms(PianoKeyCollections.eFlatDominant11)
        XCTAssert(dom11Transforms.normalForm == [.cSharp, .dSharp, .f, .g, .gSharp, .aSharp])
        XCTAssert(dom11Transforms.primeForm == [0, 2, 3, 5, 7, 9])
        assertChord(dom11Transforms.chord, .gSharp, "maj13sus2", "Root")
        
        let maj11Transforms = performCollectionTransforms(PianoKeyCollections.cMaj11)
        XCTAssert(maj11Transforms.normalForm == [.b, .c, .d, .e, .f, .g])
        XCTAssert(maj11Transforms.primeForm == [0, 1, 3, 5, 6, 8])
        assertChord(maj11Transforms.chord, .c, "maj11", "Root")
        
        let min11Transforms = performCollectionTransforms(PianoKeyCollections.eMin11)
        XCTAssert(min11Transforms.normalForm == [.d, .e, .fSharp, .g, .a, .b])
        XCTAssert(min11Transforms.primeForm == [0, 2, 4, 5, 7, 9])
        assertChord(min11Transforms.chord, .e, "m11", "4th")
        
        let sharp11Transforms = performCollectionTransforms(PianoKeyCollections.a7Sharp11)
        XCTAssert(sharp11Transforms.normalForm == [.g, .a, .b, .cSharp, .dSharp, .e])
        XCTAssert(sharp11Transforms.primeForm == [0, 1, 3, 5, 7, 9])
        assertChord(sharp11Transforms.chord, .b, "11(♯5)", "1st")
    }
    
    func testThirteenChords() {
        let dom13Transforms = performCollectionTransforms(PianoKeyCollections.aDominant13)
        XCTAssert(dom13Transforms.normalForm == [.cSharp, .d, .e, .fSharp, .g, .a, .b])
        XCTAssert(dom13Transforms.primeForm == [0, 1, 3, 5, 6, 8, 10])
        assertChord(dom13Transforms.chord, .e, "m13", "Root")
    }
        
    private func assertChord(_ chord: (root: PitchClass, quality: String, inversion: String)?,
                             _ root: PitchClass, _ quality: String, _ inversion: String,
                             file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(chord?.root, root, file: file, line: line)
        XCTAssertEqual(chord?.quality, quality, file: file, line: line)
        XCTAssertEqual(chord?.inversion, inversion, file: file, line: line)
    }
    
    private func performCollectionTransforms(_ keys: [PianoKey]) -> (normalForm: [PitchClass],
                                                                                  primeForm: [Int],
                                                                                  chord: (root: PitchClass, quality: String, inversion: String)?) {
        let pitchCollection = keys.map { $0.pitchClass }
        let normalForm = harmonyModel.normalForm(of: pitchCollection)
        let primeForm = harmonyModel.primeForm(ofCollectionInNormalForm: normalForm)
        let chord = harmonyModel.chord(from: keys)
        return (normalForm: normalForm, primeForm: primeForm, chord: chord)
    }
    
}
