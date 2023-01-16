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
    func testNoteComparable() {
        let note1 = Note(pitchClass: .c, noteLetter: .c, octave: nil)!
        let note2 = Note(pitchClass: .aSharp, noteLetter: .b, octave: nil)!

        // TODO: test when one octave is different, when octaves are the same, when octaves are nil, when one octave is nil
        XCTAssertGreaterThan(note2, note1)
    }

}
