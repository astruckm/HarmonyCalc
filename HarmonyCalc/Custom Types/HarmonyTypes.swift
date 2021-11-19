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

public enum TonalChordType: String {
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
    case sharpEleven = "⁷♯¹¹"
    
    case sharpThirteen = "⁷♭¹³"
    case thirteen = "¹³"
}
