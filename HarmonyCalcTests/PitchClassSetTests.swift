//
//  PitchClassSetTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 6/26/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

class PitchClassSetTests: XCTestCase {

    func testNormalForm() {
        XCTAssertEqual(PitchClassSet([0, 2, 8]).normalForm, [8, 0, 2])           // wraps past 0
        XCTAssertEqual(PitchClassSet([2, 6, 9]).normalForm, [2, 6, 9])           // major triad
        XCTAssertEqual(PitchClassSet([0, 3, 7]).normalForm, [0, 3, 7])           // minor triad
        XCTAssertEqual(PitchClassSet([0, 4, 8]).normalForm, [0, 4, 8])           // augmented (symmetric)
        XCTAssertEqual(PitchClassSet([2, 5, 8, 11]).normalForm, [2, 5, 8, 11])   // fully diminished 7th
        XCTAssertEqual(PitchClassSet([1, 4, 6, 10]).normalForm, [10, 1, 4, 6])   // dominant 7th
        XCTAssertEqual(PitchClassSet([2, 6, 7, 9, 11]).normalForm, [6, 7, 9, 11, 2]) // major 9th
        XCTAssertEqual(PitchClassSet([1, 7, 8, 11]).normalForm, [7, 8, 11, 1])   // all-interval tetrachord
    }

    func testPrimeForm() {
        XCTAssertEqual(PitchClassSet([0, 2, 8]).primeForm, [0, 2, 6])
        XCTAssertEqual(PitchClassSet([2, 6, 9]).primeForm, [0, 3, 7])            // packs from the inversion
        XCTAssertEqual(PitchClassSet([0, 3, 7]).primeForm, [0, 3, 7])            // packs from the original
        XCTAssertEqual(PitchClassSet([0, 4, 8]).primeForm, [0, 4, 8])
        XCTAssertEqual(PitchClassSet([2, 5, 8, 11]).primeForm, [0, 3, 6, 9])
        XCTAssertEqual(PitchClassSet([1, 4, 6, 10]).primeForm, [0, 2, 5, 8])
        XCTAssertEqual(PitchClassSet([2, 6, 7, 9, 11]).primeForm, [0, 1, 3, 5, 8])
        XCTAssertEqual(PitchClassSet([1, 7, 8, 11]).primeForm, [0, 1, 4, 6])
    }

    func testDeduplicatesOctaveDoublings() {
        XCTAssertEqual(PitchClassSet([0, 4, 7, 0]).normalForm, [0, 4, 7])
        XCTAssertEqual(PitchClassSet([0, 4, 7, 0]).primeForm, [0, 3, 7])
    }
}
