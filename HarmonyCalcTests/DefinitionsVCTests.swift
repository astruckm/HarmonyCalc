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
    func testLoadOutlets() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let sut = sb.instantiateViewController(withIdentifier: String(describing: DefinitionsViewController.self)) as! DefinitionsViewController
        // Set chordType here
        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.definition)
    }
}
