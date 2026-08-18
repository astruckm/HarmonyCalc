//
//  NoteTransformsTests.swift
//  HarmonyCalcTests
//
//  Created by Andrew Struck-Marcell on 1/16/23.
//  Copyright © 2023 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

final class NoteTransformsTests: XCTestCase {
    enum MockData {
        static var cZero: Note { makeNote(.c, 4) }
        static var cSharpZero: Note { makeNote(.cSharp, 4) }
        static var aZero: Note { makeNote(.a, 4) }
        static var cSharpOne: Note { makeNote(.cSharp, 5) }
    }
    
    func testAllInversionsOfEmptyPCollection() {
        let allInversionsEmpty = allInversions(of: [])

        XCTAssertEqual(allInversionsEmpty.count, 0)
        XCTAssertEqual(allInversionsEmpty, [[PitchClass]]())
    }

    func testAllInversionsOfSinglePitchClass() {
        let allInversionsSinglePC = allInversions(of: [.c])

        XCTAssertEqual(allInversionsSinglePC.count, 1)
        XCTAssertEqual(allInversionsSinglePC, [[.c]])
    }

    func testAllInversionsTwoPitchClassCollection() {
        let allInversionsTwoPCs = allInversions(of: [.e, .g])

        XCTAssertEqual(allInversionsTwoPCs.count, 2)
        XCTAssertEqual(allInversionsTwoPCs, [[.e, .g], [.g, .e]])
    }

    func testAllInversionsOfTriad() {
        let allInversionsTriad = allInversions(of: [.c, .e, .g])
        let allInversionsTriadFirstPCs: Set<PitchClass> = Set(allInversionsTriad.compactMap { $0.first })

        XCTAssertEqual(allInversionsTriad.count, 3)
        XCTAssertEqual(allInversionsTriadFirstPCs, [.c, .e, .g])
    }

    func testAllInversionsOf10PitchClassCollection() {
        let allInversions10PCs = allInversions(of: [.b, .aSharp, .gSharp, .g, .fSharp, .f, .e, .dSharp, .d, .c])
        let allInversions10PCsFirstPCs: Set<PitchClass> = Set(allInversions10PCs.compactMap { $0.first })

        XCTAssertEqual(allInversions10PCs.count, 10)
        XCTAssertEqual(allInversions10PCsFirstPCs, [.b, .aSharp, .gSharp, .g, .fSharp, .f, .e, .dSharp, .d, .c])
    }

    func testPutInRangeWithNegativeKeyValues() {
        let negativeOne: PitchClass = putInRange(keyValue: -1)
        let negativeTwentyFour: PitchClass = putInRange(keyValue: -24)
        let negativeOneHundred: PitchClass = putInRange(keyValue: -100)

        XCTAssertEqual(negativeOne, .b)
        XCTAssertEqual(negativeTwentyFour, .c)
        XCTAssertEqual(negativeOneHundred, .gSharp)
    }

    func testPutInRangeForKeyValueAlreadyInRange() {
        let zero: PitchClass = putInRange(keyValue: 0)
        let seven: PitchClass = putInRange(keyValue: 7)

        XCTAssertEqual(zero, .c)
        XCTAssertEqual(seven, .g)
    }

    func testPutInRangeForKeyValueAboveRange() {
        let twentyTwo: PitchClass = putInRange(keyValue: 22)
        let oneHundred: PitchClass = putInRange(keyValue: 100)

        XCTAssertEqual(twentyTwo, .aSharp)
        XCTAssertEqual(oneHundred, .e)
    }

    func testIntervalNumberBetweenNotesSameOctave() {
        let interval = intervalNumberBetweenNotes(noteOne: MockData.cSharpZero, noteTwo: MockData.aZero)

        XCTAssertEqual(interval, 8)
    }

    func testIntervalNumberBetweenNotesDifferentOctaves() {
        let intervalGreaterThanOctave = intervalNumberBetweenNotes(noteOne: MockData.cZero, noteTwo: MockData.cSharpOne)
        let intervalLessThanOctave = intervalNumberBetweenNotes(noteOne: MockData.aZero, noteTwo: MockData.cSharpOne)

        XCTAssertEqual(intervalGreaterThanOctave, 1)
        XCTAssertEqual(intervalLessThanOctave, 4)
    }

    func testIntervalNumberBetweenNotesDifferentKeyOrder() {
        let intervalSameKey = intervalNumberBetweenNotes(noteOne: MockData.aZero, noteTwo: MockData.aZero)
        let interval = intervalNumberBetweenNotes(noteOne: MockData.aZero, noteTwo: MockData.cSharpOne)
        let intervalReverse = intervalNumberBetweenNotes(noteOne: MockData.cSharpOne, noteTwo: MockData.aZero)

        XCTAssertEqual(intervalSameKey, 0)
        XCTAssertEqual(interval, 4)
        XCTAssertEqual(intervalReverse, interval)
    }
}
