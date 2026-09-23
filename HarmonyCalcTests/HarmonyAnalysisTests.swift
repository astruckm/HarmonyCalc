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

    // MARK: General chord parsing logic

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

    func testPrimaryIsNotContainedInAlternatives() {
        let inputs: [[Note]] = [
            [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4)],
            [makeNote(.e, 4), makeNote(.c, 5), makeNote(.gSharp, 5)],
            [makeNote(.c, 4), makeNote(.dSharp, 4), makeNote(.fSharp, 4), makeNote(.a, 4)],
        ]
        for notes in inputs {
            let analysis = harmonyModel.analyze(notes)
            if let primary = analysis.primary {
                XCTAssertFalse(analysis.alternatives.contains(primary))
            }
        }
    }

    func testPhantomEnharmonicExtensionsAreExcluded() {
        let c9 = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4), makeNote(.aSharp, 4), makeNote(.d, 5)]
        let analysis = harmonyModel.analyze(c9)

        let allCandidates = ([analysis.primary].compactMap { $0 }) + analysis.alternatives
        for candidate in allCandidates {
            XCTAssertFalse(candidate.quality.contains("♯9"), "phantom ♯9 in \(candidate.symbol)")
            XCTAssertFalse(candidate.quality.contains("♯11"), "phantom ♯11 in \(candidate.symbol)")
        }
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .e && $0.quality.contains("ø7") },
                      "expected the clean Eø7(add♭13) reading among alternatives")
    }

    func testAddedSixthPrefersFullerThirdStack() {
        let notes = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4), makeNote(.a, 4)]
        let analysis = harmonyModel.analyze(notes)

        XCTAssertEqual(analysis.primary?.root, .a)
        XCTAssertEqual(analysis.primary?.quality, "m7")
        XCTAssertEqual(analysis.primary?.inversion, "1st")
        XCTAssertEqual(analysis.primary?.symbol, "Am7")

        XCTAssertTrue(analysis.alternatives.contains { $0.root == .c && $0.quality == "6" })
    }

    func testPerfectFifthDyadHasNoChordButPostTonal() {
        let dyad = [makeNote(.c, 4), makeNote(.g, 4)]
        let analysis = harmonyModel.analyze(dyad)

        // Two notes clear the >= 2 pitch-class bar, so post-tonal data is computed even though
        // no tonal chord matches a bare interval.
        XCTAssertNil(analysis.primary)
        XCTAssertTrue(analysis.alternatives.isEmpty)
        XCTAssertEqual(analysis.normalForm, [.g, .c])
        XCTAssertEqual(analysis.primeForm, [0, 5])
        XCTAssertEqual(analysis.intervalVector, [0, 0, 0, 0, 1, 0])
        XCTAssertEqual(analysis.forteName, "2-5")
    }

    func testOctaveDoublingsCollapseToSameChord() {
        // A doubled root (C4 + C5) must not perturb the reading: still a plain C major triad.
        let doubled = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4), makeNote(.c, 5)]
        let analysis = harmonyModel.analyze(doubled)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "")
        XCTAssertEqual(analysis.primary?.symbol, "C")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.normalForm, [.c, .e, .g])
        XCTAssertTrue(analysis.alternatives.isEmpty)
    }

    // MARK: Triads

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

        XCTAssertTrue(analysis.alternatives.isEmpty)
        XCTAssertFalse(analysis.alternatives.contains(where: { $0 == primary }))
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

    func testAugmentedTriadResolvesToSimplestSpelling() {
        let augmented = [makeNote(.e, 4), makeNote(.c, 5), makeNote(.gSharp, 5)]
        let analysis = harmonyModel.analyze(augmented)

        // Symmetric triad: in sharps mode the simplest spelling C-E-G♯ wins over the
        // bass-rooted E⁺ (E-G♯-B♯) and A♭⁺, so C⁺ is primary with bass E as its 1st inversion.
        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "⁺")
        XCTAssertEqual(analysis.primary?.inversion, "1st")
        XCTAssertEqual(analysis.primary?.symbol, "C⁺")
        XCTAssertEqual(analysis.forteName, "3-12")
        XCTAssertEqual(analysis.alternatives.count, 2)
        XCTAssertEqual(Set(analysis.alternatives.map { $0.root }), [.e, .gSharp])
    }

    func testAugmentedTriadSpellingFollowsFlatsSetting() {
        let augmented = [makeNote(.e, 4), makeNote(.c, 5), makeNote(.gSharp, 5)]
        let analysis = harmonyModel.analyze(augmented, usingSharps: false)

        // Same pitches, flats mode: the direction tiebreak flips to A♭⁺ (A♭-C-E) over C⁺.
        XCTAssertEqual(analysis.primary?.root, .gSharp)   // pitch class 8, spelled A♭
        XCTAssertEqual(analysis.primary?.symbol, "A♭⁺")
        XCTAssertEqual(analysis.primary?.inversion, "2nd")
        XCTAssertEqual(analysis.forteName, "3-12")
        XCTAssertEqual(analysis.alternatives.count, 2)
        XCTAssertEqual(Set(analysis.alternatives.map { $0.root }), [.c, .e])

    }

    func testSuspendedChord() {
        let eSus4 = [makeNote(.e, 4), makeNote(.a, 4), makeNote(.b, 4)]
        let analysis = harmonyModel.analyze(eSus4)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "sus4")
        XCTAssertEqual(analysis.primeForm, [0, 2, 7])
        XCTAssertEqual(analysis.forteName, "3-9")
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

    func testDMajorTriadRootPosition() {
        let dMaj = [makeNote(.d, 4), makeNote(.a, 4), makeNote(.fSharp, 5)]
        let analysis = harmonyModel.analyze(dMaj)

        XCTAssertEqual(analysis.primary?.root, .d)
        XCTAssertEqual(analysis.primary?.quality, "")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.primary?.symbol, "D")
        XCTAssertEqual(analysis.normalForm, [.d, .fSharp, .a])
        XCTAssertEqual(analysis.primeForm, [0, 3, 7])
    }

    func testFMinorTriadFirstInversion() {
        let fMin = [makeNote(.gSharp, 4), makeNote(.f, 5), makeNote(.c, 5)]
        let analysis = harmonyModel.analyze(fMin)

        XCTAssertEqual(analysis.primary?.root, .f)
        XCTAssertEqual(analysis.primary?.quality, "m")
        XCTAssertEqual(analysis.primary?.inversion, "1st")
        XCTAssertEqual(analysis.normalForm, [.f, .gSharp, .c])
        XCTAssertEqual(analysis.primeForm, [0, 3, 7])
    }

    func testDiminishedTriadRootPosition() {
        let cSharpDim = [makeNote(.cSharp, 4), makeNote(.g, 4), makeNote(.e, 5)]
        let analysis = harmonyModel.analyze(cSharpDim)

        XCTAssertEqual(analysis.primary?.root, .cSharp)
        XCTAssertEqual(analysis.primary?.quality, "°")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.normalForm, [.cSharp, .e, .g])
        XCTAssertEqual(analysis.primeForm, [0, 3, 6])
    }

    // MARK: Seven chords

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
        // Symmetric 7th: in sharps mode the all-sharp spelling D♯-F♯-A-C wins over C°7
        // (whose diminished 7th is a double-flat B𝄫); bass C is D♯°7's 7th ⇒ 3rd inversion.
        XCTAssertEqual(analysis.primary?.root, .dSharp)
        XCTAssertEqual(analysis.primary?.quality, "°7")
        XCTAssertEqual(analysis.primary?.inversion, "3rd")
        XCTAssertEqual(analysis.alternatives.count, 3)
        XCTAssertTrue(analysis.alternatives.allSatisfy { $0.quality == "°7" })
        XCTAssertEqual(Set(analysis.alternatives.map { $0.root }), [.fSharp, .a, .c])
    }

    func testFullyDiminishedSpellingFollowsFlatsSetting() {
        let dim7 = [makeNote(.c, 4), makeNote(.dSharp, 4), makeNote(.fSharp, 4), makeNote(.a, 4)]
        let analysis = harmonyModel.analyze(dim7, usingSharps: false)

        // Same pitches, flats mode: the flat-leaning A°7 (A-C-E♭-G♭) wins instead of D♯°7.
        XCTAssertEqual(analysis.primary?.root, .a)
        XCTAssertEqual(analysis.primary?.symbol, "A°7")
        XCTAssertEqual(analysis.primary?.quality, "°7")
        XCTAssertEqual(analysis.primary?.inversion, "1st")
        XCTAssertEqual(analysis.alternatives.count, 3)
        XCTAssertTrue(analysis.alternatives.allSatisfy { $0.quality == "°7" })
        XCTAssertEqual(Set(analysis.alternatives.map { $0.root }), [.c, .dSharp, .fSharp])
    }

    func testFSharpDominantSeventhRootPosition() {
        let fSharp7 = [makeNote(.fSharp, 4), makeNote(.cSharp, 5), makeNote(.aSharp, 5), makeNote(.e, 5)]
        let analysis = harmonyModel.analyze(fSharp7)

        XCTAssertEqual(analysis.primary?.root, .fSharp)
        XCTAssertEqual(analysis.primary?.quality, "7")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.normalForm, [.aSharp, .cSharp, .e, .fSharp])
        XCTAssertEqual(analysis.primeForm, [0, 2, 5, 8])
    }

    func testMinorSeventhRootPositionPreferredOverAddedSixth() {
        let eMin7 = [makeNote(.e, 4), makeNote(.d, 5), makeNote(.g, 5), makeNote(.b, 5)]
        let analysis = harmonyModel.analyze(eMin7)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "m7")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.normalForm, [.b, .d, .e, .g])
        XCTAssertEqual(analysis.primeForm, [0, 3, 5, 8])
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .g && $0.quality == "6" })
    }

    func testMajorSeventhThirdInversion() {
        let eMaj7 = [makeNote(.e, 4), makeNote(.dSharp, 4), makeNote(.b, 5), makeNote(.gSharp, 4)]
        let analysis = harmonyModel.analyze(eMaj7)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "maj7")
        XCTAssertEqual(analysis.primary?.inversion, "3rd")
        XCTAssertEqual(analysis.normalForm, [.dSharp, .e, .gSharp, .b])
        XCTAssertEqual(analysis.primeForm, [0, 1, 5, 8])
    }

    func testHalfDiminishedSeventhThirdInversion() {
        let bHalfDim7 = [makeNote(.a, 4), makeNote(.b, 4), makeNote(.f, 5), makeNote(.d, 5)]
        let analysis = harmonyModel.analyze(bHalfDim7)

        XCTAssertEqual(analysis.primary?.root, .b)
        XCTAssertEqual(analysis.primary?.quality, "ø7")
        XCTAssertEqual(analysis.primary?.inversion, "3rd")
        XCTAssertEqual(analysis.normalForm, [.a, .b, .d, .f])
        XCTAssertEqual(analysis.primeForm, [0, 2, 5, 8])
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .d && $0.quality == "m6" })
    }

    func testDominantSeventhSharpFiveFirstInversion() {
        let cAug7 = [makeNote(.c, 5), makeNote(.e, 4), makeNote(.gSharp, 5), makeNote(.aSharp, 5)]
        let analysis = harmonyModel.analyze(cAug7)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "7(♯5)")
        XCTAssertEqual(analysis.primary?.inversion, "1st")
        XCTAssertEqual(analysis.normalForm, [.gSharp, .aSharp, .c, .e])
        XCTAssertEqual(analysis.primeForm, [0, 2, 4, 8])
    }

    func testAugmentedMajorSeventhFirstInversion() {
        let dAugMaj7 = [makeNote(.d, 5), makeNote(.fSharp, 4), makeNote(.cSharp, 5), makeNote(.aSharp, 4)]
        let analysis = harmonyModel.analyze(dAugMaj7)

        XCTAssertEqual(analysis.primary?.root, .d)
        XCTAssertEqual(analysis.primary?.quality, "maj7(♯5)")
        XCTAssertEqual(analysis.primary?.inversion, "1st")
        XCTAssertEqual(analysis.normalForm, [.aSharp, .cSharp, .d, .fSharp])
        XCTAssertEqual(analysis.primeForm, [0, 1, 4, 8])
    }


    // MARK: Nine chords

    func testDominantNinth() {
        let c9 = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4), makeNote(.aSharp, 4), makeNote(.d, 5)]
        let analysis = harmonyModel.analyze(c9)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "9")
        XCTAssertEqual(analysis.primeForm, [0, 2, 4, 6, 9])
        XCTAssertEqual(analysis.forteName, "5-34")
    }

    func testDominantNinthThirdInversion() {
        let fDominant9 = [makeNote(.dSharp, 4), makeNote(.f, 4), makeNote(.g, 4), makeNote(.a, 4), makeNote(.c, 5)]
        let analysis = harmonyModel.analyze(fDominant9)

        XCTAssertEqual(analysis.primary?.root, .f)
        XCTAssertEqual(analysis.primary?.quality, "9")
        XCTAssertEqual(analysis.primary?.inversion, "3rd")
        XCTAssertEqual(analysis.normalForm, [.dSharp, .f, .g, .a, .c])
        XCTAssertEqual(analysis.primeForm, [0, 2, 4, 6, 9])
    }

    func testMajorNinthThirdInversion() {
        let gMaj9 = [makeNote(.fSharp, 4), makeNote(.a, 4), makeNote(.g, 5), makeNote(.b, 5), makeNote(.d, 5)]
        let analysis = harmonyModel.analyze(gMaj9)

        XCTAssertEqual(analysis.primary?.root, .g)
        XCTAssertEqual(analysis.primary?.quality, "maj9")
        XCTAssertEqual(analysis.primary?.inversion, "3rd")
        XCTAssertEqual(analysis.normalForm, [.fSharp, .g, .a, .b, .d])
        XCTAssertEqual(analysis.primeForm, [0, 1, 3, 5, 8])
    }

    func testMinorNinthRootPosition() {
        let aMin9 = [makeNote(.e, 5), makeNote(.c, 5), makeNote(.g, 5), makeNote(.a, 4), makeNote(.b, 5)]
        let analysis = harmonyModel.analyze(aMin9)

        XCTAssertEqual(analysis.primary?.root, .a)
        XCTAssertEqual(analysis.primary?.quality, "m9")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.normalForm, [.e, .g, .a, .b, .c])
        XCTAssertEqual(analysis.primeForm, [0, 1, 3, 5, 8])
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .c && $0.quality == "maj7(add13)" })
    }

    func testDominantSeventhSharpNineFourthInversion() {
        let b7Sharp9 = [makeNote(.b, 4), makeNote(.d, 4), makeNote(.dSharp, 5), makeNote(.fSharp, 5), makeNote(.a, 5)]
        let analysis = harmonyModel.analyze(b7Sharp9)

        XCTAssertEqual(analysis.primary?.root, .b)
        XCTAssertEqual(analysis.primary?.quality, "7(♯9)")
        XCTAssertEqual(analysis.primary?.inversion, "4th")
        XCTAssertEqual(analysis.normalForm, [.a, .b, .d, .dSharp, .fSharp])
        XCTAssertEqual(analysis.primeForm, [0, 1, 4, 6, 9])
    }

    // MARK: Eleven chords

    func testSixNoteChordPrefersFullestThirdStack() {
        let cMaj11 = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4),
                      makeNote(.b, 4), makeNote(.d, 5), makeNote(.f, 5)]
        let analysis = harmonyModel.analyze(cMaj11)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "maj11")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .g })
    }

    func testDominantEleventhFifthInversion() {
        let eFlatDominant11 = [makeNote(.dSharp, 5), makeNote(.cSharp, 5), makeNote(.g, 5),
                               makeNote(.aSharp, 5), makeNote(.f, 5), makeNote(.gSharp, 4)]
        let analysis = harmonyModel.analyze(eFlatDominant11)

        XCTAssertEqual(analysis.primary?.root, .dSharp)
        XCTAssertEqual(analysis.primary?.quality, "11")
        XCTAssertEqual(analysis.primary?.inversion, "5th")
        XCTAssertEqual(analysis.normalForm, [.cSharp, .dSharp, .f, .g, .gSharp, .aSharp])
        XCTAssertEqual(analysis.primeForm, [0, 2, 3, 5, 7, 9])
    }

    func testMinorEleventhFourthInversion() {
        let eMin11 = [makeNote(.e, 5), makeNote(.b, 5), makeNote(.g, 4), makeNote(.d, 5), makeNote(.fSharp, 4), makeNote(.a, 4)]
        let analysis = harmonyModel.analyze(eMin11)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "m11")
        XCTAssertEqual(analysis.primary?.inversion, "4th")
        XCTAssertEqual(analysis.normalForm, [.d, .e, .fSharp, .g, .a, .b])
        XCTAssertEqual(analysis.primeForm, [0, 2, 4, 5, 7, 9])
    }

    func testSharpEleventhReadsAsDominantNinthSharpEleven() {
        let a7Sharp11 = [makeNote(.e, 4), makeNote(.cSharp, 5), makeNote(.g, 4), makeNote(.a, 4), makeNote(.dSharp, 4), makeNote(.b, 5)]
        let analysis = harmonyModel.analyze(a7Sharp11)

        // The clean all-sharp reading A-C♯-E-G-B-D♯ wins over B11(♯5), whose ♯5 needs a double sharp.
        XCTAssertEqual(analysis.primary?.root, .a)
        XCTAssertEqual(analysis.primary?.quality, "9(♯11)")
        XCTAssertEqual(analysis.primary?.inversion, "5th")
        XCTAssertEqual(analysis.normalForm, [.g, .a, .b, .cSharp, .dSharp, .e])
        XCTAssertEqual(analysis.primeForm, [0, 1, 3, 5, 7, 9])
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .b && $0.quality == "11(♯5)" })
    }

    // MARK: Thirteen chords

    func testSevenNoteDiatonicSetStacksAsThirteenthChord() {
        let cMajorScale = [makeNote(.c, 4), makeNote(.d, 4), makeNote(.e, 4), makeNote(.f, 4),
                           makeNote(.g, 4), makeNote(.a, 4), makeNote(.b, 4)]
        let analysis = harmonyModel.analyze(cMajorScale)

        XCTAssertEqual(analysis.primary?.root, .c)
        XCTAssertEqual(analysis.primary?.quality, "maj13")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .d && $0.quality == "m13" })
    }

    func testSixNoteChordExcludesPhantomExtensions() {
        let c13 = [makeNote(.c, 4), makeNote(.e, 4), makeNote(.g, 4),
                   makeNote(.aSharp, 4), makeNote(.d, 5), makeNote(.a, 5)]
        let analysis = harmonyModel.analyze(c13)

        XCTAssertEqual(analysis.primary?.root, .a)
        XCTAssertTrue(analysis.primary?.quality.contains("m7") ?? false)

        let allCandidates = ([analysis.primary].compactMap { $0 }) + analysis.alternatives
        for candidate in allCandidates {
            XCTAssertFalse(candidate.quality.contains("♯9"), "phantom ♯9 in \(candidate.symbol)")
        }
    }

    func testDiatonicSeventhNoteSetRootedOnBassAsMinorThirteenth() {
        let dMajorSet = [makeNote(.e, 4), makeNote(.cSharp, 5), makeNote(.g, 5), makeNote(.a, 4),
                         makeNote(.d, 5), makeNote(.fSharp, 5), makeNote(.b, 4)]
        let analysis = harmonyModel.analyze(dMajorSet)

        XCTAssertEqual(analysis.primary?.root, .e)
        XCTAssertEqual(analysis.primary?.quality, "m13")
        XCTAssertEqual(analysis.primary?.inversion, "Root")
        XCTAssertEqual(analysis.normalForm, [.cSharp, .d, .e, .fSharp, .g, .a, .b])
        XCTAssertEqual(analysis.primeForm, [0, 1, 3, 5, 6, 8, 10])
        XCTAssertTrue(analysis.alternatives.contains { $0.root == .d && $0.quality == "maj13" })
    }
}
