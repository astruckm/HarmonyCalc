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
        static let octaveZero: Octave = .zero
        static let octaveOne: Octave = .one

        static var cZero: PianoKey { (.c, octaveZero) }
        static var cSharpZero: PianoKey { (.cSharp, octaveZero) }
        static var aZero: PianoKey { (.a, octaveZero) }
        static var cSharpOne: PianoKey { (.cSharp, octaveOne) }
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

    func testKeyValue() {
        let pc: PitchClass = .aSharp
        let keyValue = keyValue((pitchClass: pc, octave: MockData.octaveOne))

        XCTAssertEqual(keyValue, 22)
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

    func testIntervalNumberBetweenKeysSameOctave() {
        let interval = intervalNumberBetweenKeys(keyOne: MockData.cSharpZero, keyTwo: MockData.aZero)

        XCTAssertEqual(interval, 8)
    }

    func testIntervalNumberBetweenKeysDifferentOctaves() {
        let intervalGreaterThanOctave = intervalNumberBetweenKeys(keyOne: MockData.cZero, keyTwo: MockData.cSharpOne)
        let intervalLessThanOctave = intervalNumberBetweenKeys(keyOne: MockData.aZero, keyTwo: MockData.cSharpOne)

        XCTAssertEqual(intervalGreaterThanOctave, 1)
        XCTAssertEqual(intervalLessThanOctave, 4)
    }

    func testIntervalNumberBetweenKeysDifferentKeyOrder() {
        let intervalSameKey = intervalNumberBetweenKeys(keyOne: MockData.aZero, keyTwo: MockData.aZero)
        let interval = intervalNumberBetweenKeys(keyOne: MockData.aZero, keyTwo: MockData.cSharpOne)
        let intervalReverse = intervalNumberBetweenKeys(keyOne: MockData.cSharpOne, keyTwo: MockData.aZero)

        XCTAssertEqual(intervalSameKey, 0)
        XCTAssertEqual(interval, 4)
        XCTAssertEqual(intervalReverse, interval)
    }
}
