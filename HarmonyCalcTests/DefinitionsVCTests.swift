//
//  DefinitionsVCTests.swift
//  HarmonyCalcTests
//
//  Created by Andrew Struck-Marcell on 1/18/23.
//  Copyright © 2023 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

final class DefinitionsVCTests: XCTestCase {
    func testLoadsDefinitionIntoViewHierarchy() {
        let sut = DefinitionsViewController()
        sut.topic = .chord
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.definition.isDescendant(of: sut.view))
        XCTAssertEqual(sut.definition.text, DefinitionsViewController.Topic.chord.text)
    }
}
