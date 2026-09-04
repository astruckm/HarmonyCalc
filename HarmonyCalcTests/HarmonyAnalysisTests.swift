//
//  HarmonyAnalysisTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 8/27/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class HarmonyAnalysisTests: XCTestCase {
    let harmonyModel = HarmonyModel(maxNotesInCollection: 88)

    func testMajorTriadPrimaryAndPostTonal() {
        let cMajor = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4)]
        let analysis = harmonyModel.analyze(cMajor)

        let primary = analysis.primary
        XCTAssertEqual(primary?.root, .c)
        XCTAssertEqual(primary?.rootSpelling, "C")
        XCTAssertEqual(primary?.quality, "")
        XCTAssertEqual(primary?.inversion, "Root")
        XCTAssertEqual(primary?.symbol, "C")

        XCTAssertEqual(analysis.normalForm, [.c, .e, .g])
        XCTAssertEqual(analysis.primeForm, [0, 3, 7])
        XCTAssertEqual(analysis.intervalVector, [0, 0, 1, 1, 1, 0])
        XCTAssertEqual(analysis.forteName, "3-11")

        XCTAssertEqual(analysis.alternatives.count, 1)
        XCTAssertEqual(analysis.alternatives.first, primary)
    }

    func testMinorTriadSharesSetClassWithMajor() {
        let cMinor = [makeNote(.c, 4), makeNote(.dSharp, 4), makeNote(.g, 4)]
        let analysis = harmonyModel.analyze(cMinor)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "m")
        XCTAssertEqual(analysis.primeForm, [0, 3, 7])
        XCTAssertEqual(analysis.forteName, "3-11")
        XCTAssertEqual(analysis.intervalVector, [0, 0, 1, 1, 1, 0])
    }

    func testAugmentedTriadHasThreeSymmetricReadings() {
        let augmented = [makeNote(.e, 4), makeNote(.c, 5), makeNote(.gSharp, 5)]
        let analysis = harmonyModel.analyze(augmented)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "⁺")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.forteName, "3-12")
        XCTAssertEqual(analysis.alternatives.count, 3)
        XCTAssertEqual(Set(analysis.alternatives.map { $0.root }), [.c, .e, .gSharp])
    }

    func testSuspendedChord() {
        let eSus4 = [makeNote(.e, 4), makeNote(.a, 4), makeNote(.b, 4)]
        let analysis = harmonyModel.analyze(eSus4)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "sus4")
        XCTAssertEqual(analysis.primeForm, [0, 2, 7])
        XCTAssertEqual(analysis.forteName, "3-9")
    }

    func testDominantSeventh() {
        let c7 = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4), makeNote(.aSharp, 4)]
        let analysis = harmonyModel.analyze(c7)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "7")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.primeForm, [0, 2, 5, 8])
        XCTAssertEqual(analysis.intervalVector, [0, 1, 2, 1, 1, 1])
        XCTAssertEqual(analysis.forteName, "4-27")
    }

    func testFullyDiminishedSeventhReadings() {
        let dim7 = [makeNote(.c, 4), makeNote(.dSharp, 4), makeNote(.fSharp, 4), makeNote(.a, 4)]
        let analysis = harmonyModel.analyze(dim7)

        XCTAssertEqual(analysis.primeForm, [0, 3, 6, 9])
        XCTAssertEqual(analysis.forteName, "4-28")
        XCTAssertEqual(analysis.primary?.quality, "°7")
        XCTAssertEqual(analysis.alternatives.count, 4)
        XCTAssertTrue(analysis.alternatives.allSatisfy { $0.quality == "°7" })
        XCTAssertEqual(Set(analysis.alternatives.map { $0.root }), [.c, .dSharp, .fSharp, .a])
    }

    func testDominantNinth() {
        let c9 = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4), makeNote(.aSharp, 4), makeNote(.d, 5)]
        let analysis = harmonyModel.analyze(c9)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "9")
        XCTAssertEqual(analysis.primeForm, [0, 2, 4, 6, 9])
        XCTAssertEqual(analysis.forteName, "5-34")
    }

    func testFlatFiveTriad() {
        let flatFive = [makeNote(.c, 4), makeNote(.d, 5), makeNote(.gSharp, 5)]
        let analysis = harmonyModel.analyze(flatFive)

        XCTAssertEqual(analysis.primary?.root, .gSharp)
        XCTAssertEqual(analysis.primary?.quality, "(♭5)")
        XCTAssertEqual(analysis.normalForm, [.gSharp, .c, .d])
        XCTAssertEqual(analysis.primeForm, [0, 2, 6])
        XCTAssertEqual(analysis.forteName, "3-8")
    }

    func testAllIntervalTetrachordHasNoChordButFullPostTonal() {
        let atonal = [makeNote(.g, 5), makeNote(.cSharp, 5), makeNote(.gSharp, 4), makeNote(.b, 5)]
        let analysis = harmonyModel.analyze(atonal)

        XCTAssertNil(analysis.primary)
        XCTAssertTrue(analysis.alternatives.isEmpty)
        XCTAssertEqual(analysis.primeForm, [0, 1, 4, 6])
        XCTAssertEqual(analysis.intervalVector, [1, 1, 1, 1, 1, 1])
        XCTAssertEqual(analysis.forteName, "4-Z15")
    }

    func testEmptySelectionIsEmptyAnalysis() {
        XCTAssertEqual(harmonyModel.analyze([]), .empty)
    }

    func testSinglePitchClassIsEmptyAnalysis() {
        let octave = [makeNote(.c, 4), makeNote(.c, 5)]
        XCTAssertEqual(harmonyModel.analyze(octave), .empty)
    }

    func testPrimaryIsContainedInAlternatives() {
        let inputs: [[Note]] = [
            [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4)],
            [makeNote(.e, 4), makeNote(.c, 5), makeNote(.gSharp, 5)],
            [makeNote(.c, 4), makeNote(.dSharp, 4), makeNote(.fSharp, 4), makeNote(.a, 4)],
        ]
        for notes in inputs {
            let analysis = harmonyModel.analyze(notes)
            if let primary = analysis.primary {
                XCTAssertTrue(analysis.alternatives.contains(primary))
            }
        }
    }
}
