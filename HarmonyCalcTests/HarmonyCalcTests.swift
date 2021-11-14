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
    var harmonyModel = HarmonyModel(maxNotesInCollection: 7)
    
    enum PitchCollections {
        // Tonal
        static let dMaj: [PitchClass] = [.d, .a, .fSharp]
        static let fMin: [PitchClass] = [.gSharp, .f, .c]
        static let cSharpDim: [PitchClass] = [.e, .cSharp, .g]
        static let cAug: [PitchClass] = [.e, .c, .gSharp]
        static let esus4: [PitchClass] = [.e, .a, .g]
        
        static let fSharpDominant7: [PitchClass] = [.fSharp, .cSharp, .aSharp, .e]
        static let eMin7: [PitchClass] = [.e, .d, .g, .b]
        static let eMaj7: [PitchClass] = [.e, .dSharp, .b, .gSharp]
        static let gSharpFullyDim7: [PitchClass] = [.gSharp, .b, .f, .d]
        static let bHalfDim7: [PitchClass] = [.a, .b, .f, .d]
        static let cAug7: [PitchClass] = [.c, .e, .gSharp, .aSharp]
        static let dAugMaj7: [PitchClass] = [.d, .fSharp, .cSharp, .aSharp]
        
        static let fDominant9: [PitchClass] = [.dSharp, .f, .g, .c, .a]
        static let gMaj9: [PitchClass] = [.fSharp, .a, .g, .b, .d]
        static let aMin9: [PitchClass] = [.e, .c, .g, .a, .b]
        static let g7Flat9: [PitchClass] = [.b, .g, .d, .gSharp, .f]
        static let b7Sharp9: [PitchClass] = [.b, .d, .dSharp, .fSharp, .a]
        
        static let eFlatDominant11: [PitchClass] = [.dSharp, .cSharp, .g, .aSharp, .f, .gSharp]
        static let cMaj11: [PitchClass] = [.e, .c, .b, .g, .f, .d]
        static let eMin11: [PitchClass] = [.e, .b, .g, .d, .f, .a]
        static let a7Sharp11: [PitchClass] = [.e, .cSharp, .g, .a, .dSharp, .b]
        
        static let d7Flat13: [PitchClass] = [.e, .aSharp, .cSharp, .g, .d, .a, .fSharp]
        static let dDominant13: [PitchClass] = [.e, .cSharp, .g, .a, .d, .fSharp, .b]
        
        // Non-tonal
        static let zeroTwoSix: [PitchClass] = [.d, .c, .gSharp]
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNontonal() {
        let pitchCollection1: [PitchClass] = PitchCollections.zeroTwoSix
        let normalFormPC: [PitchClass] = harmonyModel.normalForm(of: pitchCollection1)
        
        XCTAssert(normalFormPC == [.gSharp, .c, .d])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormPC) == [0,2,6])
        XCTAssert(harmonyModel.getChordIdentity(of: pitchCollection1) == nil)
        let keys1 = pitchCollection1.map { ($0, Octave.zero) }
        XCTAssert(harmonyModel.getChordInversion(of: keys1) == nil)
    }
    
    func testTriads() {
        let normalFormMaj = harmonyModel.normalForm(of: PitchCollections.dMaj)
        XCTAssert(normalFormMaj == [.d, .fSharp, .a])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormMaj) == [0, 3, 7])
        XCTAssert(harmonyModel.getChordIdentity(of: PitchCollections.dMaj)! == (.d, .major))
        let normalFormMajKeys = PitchCollections.dMaj.map { ($0, Octave.zero) }
        XCTAssert(harmonyModel.getChordInversion(of: normalFormMajKeys)! == "Root")
        
        let normalFormMin = harmonyModel.normalForm(of: PitchCollections.fMin)
        XCTAssert(normalFormMin == [.f, .gSharp, .c])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormMin) == [0, 3, 7])
        XCTAssert(harmonyModel.getChordIdentity(of: PitchCollections.fMin)! == (.f, .minor))
        let normalFormMinKeys = PitchCollections.fMin.enumerated().map { ($1, Octave(rawValue: ($0 + 1) / 2)!) }
        XCTAssert(harmonyModel.getChordInversion(of: normalFormMinKeys)! == "1st")
    }
    
    func testTonal() {
        // TODO: test all:
        /*
         "[3, 3]": ("o", 0),
         "[4, 4]": ("+", 0),
         "[2, 5]": ("Sus⁴", 2),
         
         "[3, 2, 3]": ("min⁷", 2),
         "[1, 4, 3]": ("Maj⁷", 1),
         "[3, 3, 3]": ("o⁷", 0),
         "[2, 2, 4]": ("+⁷", 2),
         "[3, 1, 4]": ("+Maj⁷", 2),
         
         "[3, 2, 2, 2]": ("⁹", 2),
         "[1, 2, 2, 3]": ("Maj⁹", 1),
         "[3, 2, 2, 1]": ("min⁹", 2),
         "[2, 1, 3, 3]": ("⁷♭⁹", 1),
         "[3, 3, 2, 1]": ("⁷♯⁹", 3),
         
         "[2, 2, 2, 1, 2]": ("¹¹", 1),
         "[1, 2, 2, 1, 2]": ("Maj¹¹", 1),
         "[2, 2, 1, 2, 2]": ("min¹¹", 1),
         "[2, 2, 2, 2, 1]": ("⁷♯¹¹", 1),
         
         "[2, 2, 2, 2, 1, 2]": ("⁷♭¹³", 2),
         "[1, 2, 2, 1, 2, 2]": ("¹³", 5)
*/
        
        let normalFormDom7: [PitchClass] = harmonyModel.normalForm(of: PitchCollections.fSharpDominant7)
        XCTAssert(normalFormDom7 == [.aSharp, .cSharp, .e, .fSharp])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormDom7) == [0, 2, 5, 8])
        XCTAssert(harmonyModel.getChordIdentity(of: PitchCollections.fSharpDominant7)! == (.fSharp, .dominantSeventh))
        let normalFormDom7Keys: [(PitchClass, Octave)] = [(.fSharp, .zero), (.cSharp, .one), (.aSharp, .one), (.e, .one)]
        XCTAssert(harmonyModel.getChordInversion(of: normalFormDom7Keys)! == "Root")
        
        let normalFormHalfDim7: [PitchClass] = harmonyModel.normalForm(of: PitchCollections.bHalfDim7)
        XCTAssert(normalFormHalfDim7 == [.a, .b, .d, .f])
        XCTAssert(harmonyModel.primeForm(ofCollectionInNormalForm: normalFormHalfDim7) == [0, 2, 5, 8])
        let normalFormHalfDim7Keys = PitchCollections.bHalfDim7.enumerated().map { ($1, Octave(rawValue: $0 / 2)!) }
        XCTAssert(harmonyModel.getChordInversion(of: normalFormHalfDim7Keys)! == "3rd")
    }
    

}
