//
//  ChordSymbolFormatterTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 10/3/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class ChordSymbolFormatterTests: XCTestCase {

    private func candidate(_ rootSpelling: String, _ quality: String) -> ChordCandidate {
        return ChordCandidate(root: .c, rootSpelling: rootSpelling, quality: quality, inversion: "Root")
    }

    func testStandardStyleIsUnchanged() {
        let qualities = ["", "m", "°", "⁺", "maj7", "m7", "mMaj7", "ø7", "°7", "7(♯9)", "m(add9)", "maj7sus4"]
        for quality in qualities {
            XCTAssertEqual(ChordSymbolFormatter.symbol(for: candidate("C", quality), style: .standard), "C" + quality)
        }
    }

    func testDefaultStyleIsStandard() {
        XCTAssertEqual(ChordSymbolFormatter.symbol(for: candidate("E♭", "maj7")), "E♭maj7")
    }

    func testSymbolicStyle() {
        let expected: [(String, String)] = [
            ("", "C"),
            ("m", "C−"),
            ("m7", "C−7"),
            ("m6", "C−6"),
            ("m(add9)", "C−(add9)"),
            ("m7(♭9)", "C−7(♭9)"),
            ("maj7", "CΔ7"),
            ("maj9(♯11)", "CΔ9(♯11)"),
            ("maj13sus4", "CΔ13sus4"),
            ("mMaj7", "C−Δ7"),
            ("mMaj(♭9)", "C−Δ(♭9)"),
            ("7", "C7"),
            ("7sus4", "C7sus4"),
            ("°7", "C°7"),
            ("ø7", "Cø7"),
            ("⁺", "C⁺"),
            ("6/9", "C6/9"),
        ]
        for (quality, symbol) in expected {
            XCTAssertEqual(ChordSymbolFormatter.symbol(for: candidate("C", quality), style: .symbolic), symbol, "quality \"\(quality)\"")
        }
    }

    func testSymbolicStyleKeepsRootAccidentals() {
        XCTAssertEqual(ChordSymbolFormatter.symbol(for: candidate("F♯", "m7"), style: .symbolic), "F♯−7")
        XCTAssertEqual(ChordSymbolFormatter.symbol(for: candidate("B♭", "maj7"), style: .symbolic), "B♭Δ7")
    }

    func testStyleRawValuesAreStable() {
        XCTAssertEqual(ChordSymbolStyle(rawValue: "standard"), .standard)
        XCTAssertEqual(ChordSymbolStyle(rawValue: "symbolic"), .symbolic)
    }
}
