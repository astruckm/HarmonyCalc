//
//  PitchClassSet.swift
//  HarmonyCalc
//
//  Created by ASM on 6/25/26.
//  Copyright © 2026 ASM. All rights reserved.
//
//  Post-tonal set theory, following Joseph N. Straus' "Introduction to Post-Tonal Theory".
//  Operates on bare integer pitch classes (0...11) with no spelling context, so it stays
//  independent of the rest of the app.
//

import Foundation

struct PitchClassSet {
    let pitchClasses: [Int]

    init(_ pitchClasses: [Int]) {
        self.pitchClasses = pitchClasses
    }

    // The rotation most packed to the left, comparing the interval from the first pitch class out to the last, then if there are ties, from the first to second-to-last, and so on.
    // A fully symmetric set is broken by choosing the lowest starting pitch class.
    var normalForm: [Int] {
        let deduped = Array(Set(pitchClasses)).sorted()
        guard deduped.count >= 2 else { return [] }
        let allRotations: [[Int]] = Self.allRotations(of: deduped)
        return allRotations.min(by: PitchClassSet.moreCompact) ?? pitchClasses
    }

    // The prime form (Rahn method): the most left-packed of the normal form or its inversion's normal form, transposed to begin on 0.
    var primeForm: [Int] {
        let normalForm = self.normalForm
        guard normalForm.count >= 2 else { return [] }

        let original = PitchClassSet.transposedToZero(normalForm)
        let invertedNormalForm = PitchClassSet(normalForm.map { PitchClassSet.mod12(-$0) }).normalForm
        let inversion = PitchClassSet.transposedToZero(invertedNormalForm)
        return PitchClassSet.moreLeftPacked(original, inversion)
    }

    // The interval-class vector: how many times each interval class (1...6) occurs in the set.
    var intervalVector: [Int] {
        let pcs = Array(Set(pitchClasses))
        var vector = [Int](repeating: 0, count: 6)
        guard pcs.count >= 2 else { return vector }
        for i in 0..<(pcs.count - 1) {
            for j in (i + 1)..<pcs.count {
                vector[PitchClassSet.intervalClass(between: pcs[i], and: pcs[j]) - 1] += 1
            }
        }
        return vector
    }

    // MARK: - Helpers

    private static func mod12(_ value: Int) -> Int {
        let remainder = value % 12
        return remainder < 0 ? remainder + 12 : remainder
    }

    private static func intervalClass(between first: Int, and second: Int) -> Int {
        let semitones = mod12(abs(first - second))
        return semitones <= 6 ? semitones : 12 - semitones
    }

    private static func allRotations(of sortedCollection: [Int]) -> [[Int]] {
        guard !sortedCollection.isEmpty else { return [] }
        var rotations = [[Int]]()
        var rotation = sortedCollection
        for _ in 0..<sortedCollection.count {
            rotations.append(rotation)
            rotation.append(rotation.removeFirst())
        }
        return rotations
    }

    // True when `a` is strictly more compact than `b`: compare the span from the first pitch class to the last, then to the second-to-last, etc.; ties among fully symmetric rotations fall back to the lower starting pitch class for a stable ordering.
    private static func moreCompact(_ a: [Int], _ b: [Int]) -> Bool {
        for offset in stride(from: a.count - 1, through: 1, by: -1) {
            let spanA = mod12(a[offset] - a[0])
            let spanB = mod12(b[offset] - b[0])
            if spanA != spanB { return spanA < spanB }
        }
        return a[0] < b[0]
    }

    private static func transposedToZero(_ set: [Int]) -> [Int] {
        guard let first = set.first else { return [] }
        return set.map { mod12($0 - first) }
    }

    // The more left-packed of two zero-based candidates: the one with the smaller pitch class
    // at the first position where they differ (Straus' prime form comparison).
    private static func moreLeftPacked(_ a: [Int], _ b: [Int]) -> [Int] {
        for index in 1..<a.count {
            if a[index] != b[index] { return a[index] < b[index] ? a : b }
        }
        return a
    }
}
