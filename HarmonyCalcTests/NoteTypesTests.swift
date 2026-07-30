//
//  NoteTypesTests.swift
//  HarmonyCalcTests
//
//  Created by Andrew Struck-Marcell on 1/16/23.
//  Copyright © 2023 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

final class NoteTypesTests: XCTestCase {
    func testOctaveInit() {
        let negative = Octave(rawValue: -1)
        let zero = Octave(rawValue: 0)
        let ninetyNine = Octave(rawValue: 99)

        XCTAssertNil(negative)
        XCTAssertNotNil(zero)
        XCTAssertEqual(zero, Octave.zero)
        XCTAssertNil(ninetyNine)
    }

    func testNoteInit() {
        let impossibleNote = Note(pitchClass: .c, noteLetter: .g, octave: .one)
        let aSharp = Note(pitchClass: .aSharp, noteLetter: .a, octave: .zero)
        let aSharpOctaveNil = Note(pitchClass: .aSharp, noteLetter: .a, octave: nil)

        XCTAssertNil(impossibleNote)
        XCTAssertNotNil(aSharp)
        XCTAssertNotNil(aSharpOctaveNil)
    }

    func testNoteComparableDifferentOctavesSamePC() {
        guard let cSharpZero = Note(pitchClass: .cSharp, noteLetter: .c, octave: .zero),
              let cSharpOne = Note(pitchClass: .cSharp, noteLetter: .c, octave: .one) else {
            XCTFail("Could not init Notes")
            return
        }

        XCTAssertLessThan(cSharpZero, cSharpOne)
    }

    func testNoteComparableSameOctaveDifferentPC() {
        guard let cSharpZero = Note(pitchClass: .cSharp, noteLetter: .c, octave: .zero),
              let bFlatZero = Note(pitchClass: .aSharp, noteLetter: .b, octave: .zero) else {
                  XCTFail("Could not init Notes")
                  return
              }

        XCTAssertLessThan(cSharpZero, bFlatZero)
    }

    func testNoteComparableOneOctaveNil() {
        guard let cSharpZero = Note(pitchClass: .cSharp, noteLetter: .c, octave: .zero),
              let bFlat = Note(pitchClass: .aSharp, noteLetter: .b, octave: nil) else {
            XCTFail("Could not init Notes")
            return
        }

        XCTAssertLessThan(cSharpZero, bFlat)
    }

    func testNoteComparableBothOctavesNil() {
        guard let cNatural = Note(pitchClass: .c, noteLetter: .c, octave: nil),
              let bFlat = Note(pitchClass: .aSharp, noteLetter: .b, octave: nil) else {
            XCTFail("Could not init Notes")
            return
        }

        // TODO: enharmonically equal, weird enharmonic where lower note letter is greater
        XCTAssertLessThan(cNatural, bFlat)
    }

    func testNoteComparableEnharmonicallyEqual() {
        guard let aSharp = Note(pitchClass: .aSharp, noteLetter: .a, octave: nil),
              let bFlat = Note(pitchClass: .aSharp, noteLetter: .b, octave: nil) else {
            XCTFail("Could not init Notes when both octaves are nil")
            return
        }

        XCTAssertGreaterThanOrEqual(aSharp, bFlat)
    }

    func testNoteComparableEnharmonicReversal() {
        guard let fFlat = Note(pitchClass: .e, noteLetter: .f, octave: .one),
              let eSharp = Note(pitchClass: .f, noteLetter: .e, octave: .one) else {
            XCTFail("Could not init Notes for unusual enharmonic spellings")
            return
        }

        XCTAssertLessThan(fFlat, eSharp)
    }

}
