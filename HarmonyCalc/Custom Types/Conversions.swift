//
//  Conversions.swift
//  HarmonyCalc
//
//  Created by ASM on 1/16/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation

//TODO: (Note, Note) -> Interval

public struct Conversions {
    static func pitchIntervalClass(between note1: Note, and note2: Note) -> PitchIntervalClass {
        //TODO: handle when you don't know the octave, only which note is higher
        let semitonesDiff = intervalNumberBetweenKeys(keyOne: (note1.pitchClass, note1.octave ?? .zero), keyTwo: (note2.pitchClass, note2.octave ?? .zero))
        if let pIClass = PitchIntervalClass(rawValue: semitonesDiff) {
            return pIClass
        }
        print("Error deriving pitch interval class from notes!")
        return .zero
    }
    
    //assumes the notes are already spelled correctly
    static func intervalDiatonicSize(between note1: Note, and note2: Note) -> IntervalDiatonicSize {
        //TODO: need to know which note is higher
        let absStepsAway = abs(note1.noteLetter.abstractTonalScaleDegree - note2.noteLetter.abstractTonalScaleDegree)
        let noteLetterDiff = note1 > note2 ? absStepsAway : -absStepsAway
        let stepsAway = (noteLetterDiff + NoteLetter.allCases.count) % NoteLetter.allCases.count
        for size in IntervalDiatonicSize.allCases {
            if size.numSteps == stepsAway { return size }
        }
        print("Error deriving interval's within-octave diatonic size")
        return IntervalDiatonicSize.unison
    }

}
