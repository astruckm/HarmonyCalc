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

import Foundation

struct PitchClassSet {
    let pitchClasses: [Int]

    init(_ pitchClasses: [Int]) {
        self.pitchClasses = pitchClasses
    }

    // The most left-packed rotation of the set (Straus normal form).
    var normalForm: [Int] {
        let deduped = Array(Set(pitchClasses))
        guard pitchClasses.count >= 2 else { return [] }
        let rotations = PitchClassSet.allRotations(of: deduped)

        let shortest = shortestSpanRotations(of: rotations)
        if shortest.count == 1 { return shortest[0] }

        return mostPackedRotation(of: shortest) ?? rotations[0]
    }

    // The prime form (Forte method, packed to the left), transposed to begin on 0.
    var primeForm: [Int] {
        let normalForm = self.normalForm
        guard normalForm.count >= 2 else { return [] }

        let transposedToZero = normalForm.map { PitchClassSet.mod12($0 - normalForm[0]) }
        let inversion = inversionTransposedToZero(of: normalForm)
        return packedToLeft(transposedToZero, inversion)
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

    // Span in semitones, mod 12, from the first to the last pitch class of a rotation.
    private static func span(of rotation: [Int]) -> Int {
        guard let first = rotation.first, let last = rotation.last else { return 0 }
        return mod12(last - first)
    }

    private static func allRotations(of collection: [Int]) -> [[Int]] {
        guard !collection.isEmpty else { return [] }
        var rotations = [[Int]]()
        var rotation = collection.sorted()
        for _ in 0..<collection.count {
            rotations.append(rotation)
            rotation.append(rotation.removeFirst())
        }
        return rotations
    }

    private func shortestSpanRotations(of rotations: [[Int]]) -> [[Int]] {
        var shortestDistance = 12
        var shortest = [[Int]]()
        for rotation in rotations {
            let intervalSpan = PitchClassSet.span(of: rotation)
            if intervalSpan < shortestDistance {
                shortest = [rotation]
                shortestDistance = intervalSpan
            } else if intervalSpan == shortestDistance {
                shortest.append(rotation)
            }
        }
        return shortest
    }

    // Tie-break by comparing the span to the second-to-last pitch, then third-to-last, etc.
    private func mostPackedRotation(of rotations: [[Int]]) -> [Int]? {
        var shortestDistance = 12
        var shortest = [[Int]]()
        for offset in 0...(rotations[0].count - 1) {
            for rotation in rotations {
                let top = rotation[rotation.count - 1 - offset]
                let intervalSpan = PitchClassSet.mod12(top - rotation[0])
                if intervalSpan < shortestDistance {
                    shortest = [rotation]
                    shortestDistance = intervalSpan
                } else if intervalSpan == shortestDistance {
                    shortest.append(rotation)
                }
            }
            if shortest.count == 1 { return shortest[0] }
        }
        return nil
    }

    private func inversionTransposedToZero(of set: [Int]) -> [Int] {
        let inverted = set.map { PitchClassSet.mod12(12 - $0) }
        guard let last = inverted.last else { return [] }
        return inverted.map { PitchClassSet.mod12($0 - last) }.sorted()
    }

    private func packedToLeft(_ original: [Int], _ inversion: [Int]) -> [Int] {
        var index = 1
        while index < original.count {
            if original[index] < inversion[index] { return original }
            if original[index] > inversion[index] { return inversion }
            index += 1
        }
        return original
    }
}
