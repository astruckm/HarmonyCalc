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
    case dominantSeventh = "⁷"
    case minorSeventh = "min⁷"
    case majorSeventh = "Maj⁷"
    case diminishedSeventh = "o⁷"
    case halfDiminishedSeventh = "ø⁷"
}
