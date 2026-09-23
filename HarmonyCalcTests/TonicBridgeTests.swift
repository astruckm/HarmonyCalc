//
//  TonicBridgeTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 9/18/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import XCTest
import Tonic
@testable import HarmonyCalc

class TonicBridgeTests: XCTestCase {

    // MARK: pitchClass(from:)

    func testPitchClassFromNoteClass() {
        XCTAssertEqual(pitchClass(from: NoteClass(.C, accidental: .natural)), .c)
        XCTAssertEqual(pitchClass(from: NoteClass(.C, accidental: .sharp)), .cSharp)
        XCTAssertEqual(pitchClass(from: NoteClass(.A, accidental: .natural)), .a)
    }

    func testPitchClassFromNoteClassWrapsEnharmonically() {
        // Spelling is discarded: B♯ and C♭ collapse onto their sounding pitch classes.
        XCTAssertEqual(pitchClass(from: NoteClass(.B, accidental: .sharp)), .c)
        XCTAssertEqual(pitchClass(from: NoteClass(.C, accidental: .flat)), .b)
    }

    // MARK: spellingComplexity(of:)

    func testSpellingComplexityCountsAccidentalDistance() {
        XCTAssertEqual(spellingComplexity(of: NoteClass(.C, accidental: .natural)), 0)
        XCTAssertEqual(spellingComplexity(of: NoteClass(.C, accidental: .sharp)), 1)
        XCTAssertEqual(spellingComplexity(of: NoteClass(.C, accidental: .flat)), 1)
        XCTAssertEqual(spellingComplexity(of: NoteClass(.C, accidental: .doubleSharp)), 2)
        XCTAssertEqual(spellingComplexity(of: NoteClass(.C, accidental: .doubleFlat)), 2)
    }

    // MARK: spellingComplexity(of chord:)

    func testChordSpellingComplexitySumsEveryTone() {
        // Augmented triad readings of one pitch-class set: C-E-G♯ (one sharp) is simpler than E-G♯-B♯ (two sharps); A♭-C-E ties C at one flat.
        XCTAssertEqual(spellingComplexity(of: Chord(NoteClass(.C, accidental: .natural), type: .aug)), 1)
        XCTAssertEqual(spellingComplexity(of: Chord(NoteClass(.E, accidental: .natural), type: .aug)), 2)
        XCTAssertEqual(spellingComplexity(of: Chord(NoteClass(.A, accidental: .flat), type: .aug)), 1)
        // Diminished 7ths: C°7 has a double-flat 7th (B𝄫), costlier than the all-single spellings.
        XCTAssertEqual(spellingComplexity(of: Chord(NoteClass(.C, accidental: .natural), type: .dim7)), 4)
        XCTAssertEqual(spellingComplexity(of: Chord(NoteClass(.D, accidental: .sharp), type: .dim7)), 2)
        XCTAssertEqual(spellingComplexity(of: Chord(NoteClass(.A, accidental: .natural), type: .dim7)), 2)
    }

    // MARK: accidentalsAgainstDirection(of:usingSharps:)

    func testAccidentalsAgainstDirectionCountsWrongWaySpellings() {
        let cAug = Chord(NoteClass(.C, accidental: .natural), type: .aug)
        XCTAssertEqual(accidentalsAgainstDirection(of: cAug, usingSharps: true), 0)
        XCTAssertEqual(accidentalsAgainstDirection(of: cAug, usingSharps: false), 1)

        let aFlatAug = Chord(NoteClass(.A, accidental: .flat), type: .aug)
        XCTAssertEqual(accidentalsAgainstDirection(of: aFlatAug, usingSharps: true), 1)
        XCTAssertEqual(accidentalsAgainstDirection(of: aFlatAug, usingSharps: false), 0)

        let dSharpDim7 = Chord(NoteClass(.D, accidental: .sharp), type: .dim7)
        XCTAssertEqual(accidentalsAgainstDirection(of: dSharpDim7, usingSharps: true), 0)
        XCTAssertEqual(accidentalsAgainstDirection(of: dSharpDim7, usingSharps: false), 2)

        let aDim7 = Chord(NoteClass(.A, accidental: .natural), type: .dim7)
        XCTAssertEqual(accidentalsAgainstDirection(of: aDim7, usingSharps: true), 2)
        XCTAssertEqual(accidentalsAgainstDirection(of: aDim7, usingSharps: false), 0)
    }

    // MARK: tertianThirdCount(of:)

    func testTertianThirdCountCountsUnbrokenStack() {
        // Each of these is a clean stack of thirds, so the count equals its number of tones.
        XCTAssertEqual(tertianThirdCount(of: cChord(.major)), 3)   // C-E-G
        XCTAssertEqual(tertianThirdCount(of: cChord(.min7)), 4)    // C-E♭-G-B♭
        XCTAssertEqual(tertianThirdCount(of: cChord(.dom9)), 5)    // C-E-G-B♭-D
        XCTAssertEqual(tertianThirdCount(of: cChord(.maj11)), 6)   // C-E-G-B-D-F
        XCTAssertEqual(tertianThirdCount(of: cChord(.maj13)), 7)   // C-E-G-B-D-F-A
    }

    func testTertianThirdCountStopsAtFirstNonThird() {
        // A sixth breaks the stack after the triad (G→A is a second, not a third), and a suspension has no third above the root at all.
        XCTAssertEqual(tertianThirdCount(of: cChord(.maj6)), 3)    // C-E-G then A (a 2nd above G)
        XCTAssertEqual(tertianThirdCount(of: cChord(.sus4)), 1)    // C then F (a 4th above C)
    }

    // MARK: TonalChordInversion

    func testTonalChordInversionMapsIndexToLabel() {
        let labels = (0...6).map { TonalChordInversion(inversionIndex: $0).rawValue }
        XCTAssertEqual(labels, ["Root", "1st", "2nd", "3rd", "4th", "5th", "6th"])
    }

    func testTonalChordInversionWrapsPastSeven() {
        // There are seven cases, so the index cycles (e.g. a 7-note chord's 7th tone).
        XCTAssertEqual(TonalChordInversion(inversionIndex: 7).rawValue, "Root")
        XCTAssertEqual(TonalChordInversion(inversionIndex: 8).rawValue, "1st")
    }

    private func cChord(_ type: ChordType) -> Chord {
        return Chord(NoteClass(.C, accidental: .natural), type: type)
    }
}
