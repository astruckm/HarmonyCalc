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
    func testAllInversions() {
        let allInversionsEmpty = allInversions(of: [])
        let allInversionsSinglePC = allInversions(of: [.c])
        let allInversionsTwoPCs = allInversions(of: [.e, .g])
        let allInversionsTriad = allInversions(of: [.c, .e, .g])
        let allInversionsTriadFirstPCs: Set<PitchClass> = Set(allInversionsTriad.compactMap { $0.first })
        let allInversions10PCs = allInversions(of: [.b, .aSharp, .gSharp, .g, .fSharp, .f, .e, .dSharp, .d, .c])
        let allInversions10PCsFirstPCs: Set<PitchClass> = Set(allInversions10PCs.compactMap { $0.first })

        XCTAssertEqual(allInversionsEmpty.count, 0)
        XCTAssertEqual(allInversionsEmpty, [[PitchClass]]())

        XCTAssertEqual(allInversionsSinglePC.count, 1)
        XCTAssertEqual(allInversionsSinglePC, [[.c]])

        XCTAssertEqual(allInversionsTwoPCs.count, 2)
        XCTAssertEqual(allInversionsTwoPCs, [[.e, .g], [.g, .e]])

        XCTAssertEqual(allInversionsTriad.count, 3)
        XCTAssertEqual(allInversionsTriadFirstPCs, [.c, .e, .g])

        XCTAssertEqual(allInversions10PCs.count, 10)
        XCTAssertEqual(allInversions10PCsFirstPCs, [.b, .aSharp, .gSharp, .g, .fSharp, .f, .e, .dSharp, .d, .c])
    }
}
