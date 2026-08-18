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
    func testNoteInitMidiRange() {
        XCTAssertNil(Note(midiNoteNumber: -1))
        XCTAssertNil(Note(midiNoteNumber: 128))
        XCTAssertNotNil(Note(midiNoteNumber: 0))
        XCTAssertNotNil(Note(midiNoteNumber: 60))
        XCTAssertNotNil(Note(midiNoteNumber: 127))
    }

    func testNoteInitSpelling() {
        let impossibleNote = Note(pitchClass: .c, octave: 5, preferredSpelling: .g)
        let aSharp = Note(pitchClass: .aSharp, octave: 4, preferredSpelling: .a)
        let aSharpNoSpelling = Note(pitchClass: .aSharp, octave: 4)

        XCTAssertNil(impossibleNote)
        XCTAssertNotNil(aSharp)
        XCTAssertNotNil(aSharpNoSpelling)
    }

    func testMidiDerivesPitchClassAndOctave() {
        XCTAssertEqual(Note(midiNoteNumber: 60)?.pitchClass, .c)
        XCTAssertEqual(Note(midiNoteNumber: 60)?.octave, 4)
        XCTAssertEqual(Note(midiNoteNumber: 61)?.pitchClass, .cSharp)
        XCTAssertEqual(Note(midiNoteNumber: 72)?.pitchClass, .c)
        XCTAssertEqual(Note(midiNoteNumber: 72)?.octave, 5)
        XCTAssertEqual(Note(pitchClass: .a, octave: 4)?.midiNoteNumber, 69)
    }

    func testDescriptionUsesPreferredSpelling() {
        XCTAssertEqual(Note(midiNoteNumber: 61)?.description, "C♯")
        XCTAssertEqual(Note(pitchClass: .cSharp, octave: 4, preferredSpelling: .d)?.description, "D♭")
        XCTAssertEqual(Note(pitchClass: .aSharp, octave: 4, preferredSpelling: .b)?.description, "B♭")
        XCTAssertEqual(Note(pitchClass: .e, octave: 4, preferredSpelling: .f)?.description, "F♭")
    }

    func testNoteComparableDifferentOctavesSamePC() {
        guard let cSharpFour = Note(pitchClass: .cSharp, octave: 4),
              let cSharpFive = Note(pitchClass: .cSharp, octave: 5) else {
            XCTFail("Could not init Notes")
            return
        }

        XCTAssertLessThan(cSharpFour, cSharpFive)
    }

    func testNoteComparableSameOctaveDifferentPC() {
        guard let cSharpFour = Note(pitchClass: .cSharp, octave: 4),
              let bFlatFour = Note(pitchClass: .aSharp, octave: 4, preferredSpelling: .b) else {
            XCTFail("Could not init Notes")
            return
        }

        XCTAssertLessThan(cSharpFour, bFlatFour)
    }

    func testNoteComparableEnharmonicReversal() {
        guard let fFlat = Note(pitchClass: .e, octave: 5, preferredSpelling: .f),
              let eSharp = Note(pitchClass: .f, octave: 5, preferredSpelling: .e) else {
            XCTFail("Could not init Notes for unusual enharmonic spellings")
            return
        }

        XCTAssertLessThan(fFlat, eSharp)
    }

    func testEnharmonicNotesAreEqualButNamedDifferently() {
        guard let aSharp = Note(pitchClass: .aSharp, octave: 4, preferredSpelling: .a),
              let bFlat = Note(pitchClass: .aSharp, octave: 4, preferredSpelling: .b) else {
            XCTFail("Could not init Notes")
            return
        }

        XCTAssertEqual(aSharp, bFlat)
        XCTAssertEqual(aSharp.description, "A♯")
        XCTAssertEqual(bFlat.description, "B♭")
    }
}
