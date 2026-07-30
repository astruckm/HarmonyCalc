//
//  ExtensionsTests.swift
//  HarmonyCalcTests
//
//  Created by Andrew Struck-Marcell on 1/16/23.
//  Copyright © 2023 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

final class ExtensionsTests: XCTestCase {
    let arr = [2, 7, 8, 1, -6]

    func testNextIfIndexNotLastIndex() {
        let currentIdx1 = 2
        let currentIdx2 = 0

        XCTAssertEqual(arr.next(after: currentIdx1), 3)
        XCTAssertEqual(arr.next(after: currentIdx2), 1)
    }

    func testNextIfIndexIsLastIndex() {
        let currentIdx = arr.count - 1

        XCTAssertEqual(arr.next(after: currentIdx), 0)
    }

    func testPrevIfIndexNotFirstIndex() {
        let currentIdx1 = 2
        let currentIdx2 = 4

        XCTAssertEqual(arr.prev(before: currentIdx1), 1)
        XCTAssertEqual(arr.prev(before: currentIdx2), 3)
    }

    func testPrevIfIndexIsFirstIndex() {
        let currentIdx = 0

        XCTAssertEqual(arr.prev(before: currentIdx), 4)
    }

}
