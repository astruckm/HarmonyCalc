//
//  ForteTableTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 8/27/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class ForteTableTests: XCTestCase {

    func testTrichords() {
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 3, 7]), "3-11")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 3, 6]), "3-10")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 4, 8]), "3-12")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 2, 7]), "3-9")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2]), "3-1")
    }

    func testTetrachords() {
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 2, 5, 8]), "4-27")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 3, 5, 8]), "4-26")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 5, 8]), "4-20")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 3, 6, 9]), "4-28")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 2, 6, 8]), "4-25")
    }

    func testZRelatedPairsAreDistinct() {
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 4, 6]), "4-Z15")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 3, 7]), "4-Z29")
    }

    func testLargerCardinalities() {
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 2, 4, 6, 9]), "5-34")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 3, 5, 8]), "5-27")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 2, 4, 6, 8, 10]), "6-35")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 5]), "6-1")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 3, 5, 6, 8, 10]), "7-35")
    }

    func testCardinalityBoundsReturnNil() {
        XCTAssertNil(ForteTable.name(forPrimeForm: []))
        XCTAssertNil(ForteTable.name(forPrimeForm: [0]))
    }

    func testDyadsAndLargeCardinalities() {
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1]), "2-1")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 6]), "2-6")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 5, 6, 7]), "8-1")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 6, 8, 10]), "8-21")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 5, 6, 7, 8]), "9-1")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]), "10-1")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), "11-1")
        XCTAssertEqual(ForteTable.name(forPrimeForm: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]), "12-1")
    }

    func testEveryKeyIsStableUnderPrimeForm() {
        for (key, forte) in ForteTable.namesByPrimeForm {
            let pitchClasses = key.split(separator: ",").compactMap { Int($0) }
            let recomputed = PitchClassSet(pitchClasses).primeForm
            XCTAssertEqual(ForteTable.name(forPrimeForm: recomputed), forte,
                           "Key \(key) is unstable under PitchClassSet.primeForm (got \(recomputed))")
        }
    }
}
