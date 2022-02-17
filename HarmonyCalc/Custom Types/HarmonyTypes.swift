//
//  HarmonyTypes.swift
//  HarmonyCalc
//
//  Created by ASM on 8/15/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

//MARK: Intervals

public enum PitchIntervalClass: Int, Hashable, Equatable {
    case zero = 0, one, two, three, four, five, six, seven, eight, nine, ten, eleven
    
}

public enum IntervalQuality: String, CaseIterable, Comparable, Equatable {
    case diminished, minor, perfect, major, augmented

    public static func < (lhs: IntervalQuality, rhs: IntervalQuality) -> Bool {
        let lhsIndex = IntervalQuality.allCases.firstIndex(of: lhs)!
        let rhsIndex = IntervalQuality.allCases.firstIndex(of: rhs)!
        return lhsIndex < rhsIndex
    }
    
}

public enum TonalChordType: String, CaseIterable {
    case major = "Maj"
    case minor = "min"
    case diminished = "o"
    case augmented = "+"
    case suspended = "Sus"
    
    case dominantSeven = "⁷"
    case minorSeven = "min⁷"
    case majorSeven = "Maj⁷"
    case diminishedSeven = "o⁷"
    case halfDiminishedSeven = "ø⁷"
    case augmentedSeven = "+⁷"
    case augmentedMajorSeven = "+Maj⁷"
    
    case dominantNine = "⁹"
    case majorNine = "Maj⁹"
    case minorNine = "min⁹"
    case flatNine = "⁷♭⁹"
    case sharpNine = "⁷♯⁹"
    
    case eleven = "¹¹"
    case majorEleven = "Maj¹¹"
    case minorEleven = "min¹¹"
    case sharpEleven = "♯¹¹"
    
    case thirteen = "¹³"
    
    /// Ascending intervals when the chord is in normal form
    var intervalsInNormalForm: [Int] {
        switch self {
        case .major: return [4, 3] // e.g. [g, b, d]
        case .minor: return [3, 4]
        case .diminished: return [3, 3]
        case .augmented: return [4, 4]
        case .suspended: return [2, 5]
        case .dominantSeven: return [3, 3, 2] // e.g. [b, d, f, g] -> [0, 3, 6, 8]
        case .minorSeven: return [3, 2, 3]
        case .majorSeven: return [1, 4, 3]
        case .diminishedSeven: return [3, 3, 3]
        case .halfDiminishedSeven: return [2, 3, 3]
        case .augmentedSeven: return [2, 2, 4]
        case .augmentedMajorSeven: return [3, 1, 4]
        case .dominantNine: return [2, 2, 2, 3] // e.g. [f, g, a, b, d] -> [0, 2, 4, 6, 9]
        case .majorNine: return [1, 2, 2, 3]
        case .minorNine: return [3, 2, 2, 1]
        case .flatNine: return [2, 1, 3, 3]
        case .sharpNine: return [2, 3, 1, 3]
        case .eleven: return [2, 2, 2, 1, 2] // e.g. [f, g, a, b, c, d]
        case .majorEleven: return [1, 2, 2, 1, 2]
        case .minorEleven: return [2, 2, 1, 2, 2]
        case .sharpEleven: return [2, 2, 2, 2, 1]
        case .thirteen: return [1, 2, 2, 1, 2, 2] // e.g. [b, c, d, e, f, g, a], root is g
        }
    }
    
    /// The normal form of the chord with 0 / C as the lowest note
    var zeroBasedNormalForm: [Int] {
        switch self {
        case .major: return [0, 4, 7] // e.g. [g, b, d]
        case .minor: return [0, 3, 7]
        case .diminished: return [0, 3, 6]
        case .augmented: return [0, 4, 8]
        case .suspended: return [0, 2, 7]
        case .dominantSeven: return [0, 3, 6, 8] // e.g. [b, d, f, g] -> [0, 3, 6, 8]
        case .minorSeven: return [0, 3, 5, 8]
        case .majorSeven: return [0, 1, 5, 8]
        case .diminishedSeven: return [0, 3, 6, 9]
        case .halfDiminishedSeven: return [0, 2, 5, 8]
        case .augmentedSeven: return [0, 2, 4, 8]
        case .augmentedMajorSeven: return [0, 3, 4, 8]
        case .dominantNine: return [0, 2, 4, 6, 9] // e.g. [f, g, a, b, d] -> [0, 2, 4, 6, 9]
        case .majorNine: return [0, 1, 3, 5, 8]
        case .minorNine: return [0, 3, 5, 7, 8]
        case .flatNine: return [0, 2, 3, 6, 9]
        case .sharpNine: return [0, 2, 5, 6, 9]
        case .eleven: return [0, 2, 4, 6, 7, 9] // e.g. [f, g, a, b, c, d]
        case .majorEleven: return [0, 1, 3, 5, 6, 8]
        case .minorEleven: return [0, 2, 4, 5, 7, 9]
        case .sharpEleven: return [0, 2, 4, 6, 8, 9]
        case .thirteen: return [0, 1, 3, 5, 6, 8, 10] // e.g. [b, c, d, e, f, g, a], root is g
        }

    }
    
    var rootIndexInNormalForm: Int {
        switch self {
        case .major: return 0
        case .minor: return 0
        case .diminished: return 0
        case .augmented: return 0
        case .suspended: return 2
        case .dominantSeven: return 3
        case .minorSeven: return 2
        case .majorSeven: return 1
        case .diminishedSeven: return 0
        case .halfDiminishedSeven: return 1
        case .augmentedSeven: return 2
        case .augmentedMajorSeven: return 2
        case .dominantNine: return 1
        case .majorNine: return 1
        case .minorNine: return 2
        case .flatNine: return 1
        case .sharpNine: return 1
        case .eleven: return 1
        case .majorEleven: return 1
        case .minorEleven: return 1
        case .sharpEleven: return 1
        case .thirteen: return 5
        }
    }
    
}

enum TonalChordInversion: String, CaseIterable {
    case root = "Root"
    case first = "1st"
    case second = "2nd"
    case third = "3rd"
    case fourth = "4th"
    case fifth = "5th"
    case sixth = "6th"

    init(numThirdsAboveRoot: Int) {
        let numThirds = numThirdsAboveRoot % TonalChordInversion.allCases.count
        self = TonalChordInversion.allCases[numThirds]
    }
}
