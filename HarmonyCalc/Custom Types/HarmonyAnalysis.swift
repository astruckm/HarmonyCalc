//
//  HarmonyAnalysis.swift
//  HarmonyCalc
//
//  Created by ASM on 8/27/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import Foundation

struct ChordCandidate: Equatable {
    let root: PitchClass
    let rootSpelling: String
    let quality: String
    let inversion: String

    var symbol: String { return rootSpelling + quality }
}

struct HarmonyAnalysis: Equatable {
    let primary: ChordCandidate?
    let alternatives: [ChordCandidate]
    let normalForm: [PitchClass]
    let primeForm: [Int]
    let intervalVector: [Int]
    let forteName: String?

    static let empty = HarmonyAnalysis(primary: nil,
                                       alternatives: [],
                                       normalForm: [],
                                       primeForm: [],
                                       intervalVector: [0, 0, 0, 0, 0, 0],
                                       forteName: nil)
}
