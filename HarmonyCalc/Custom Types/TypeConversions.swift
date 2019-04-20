//
//  Conversions.swift
//  HarmonyCalc
//
//  Created by ASM on 1/16/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation



func pitchIntervalClass(between note1: Note, and note2: Note) -> PitchIntervalClass {
    //when you don't know the octave, assume they're in the same octave
    let semitonesDiff = intervalNumberBetweenKeys(keyOne: (note1.pitchClass, note1.octave ?? (note2.octave ?? .zero)), keyTwo: (note2.pitchClass, note2.octave ?? (note1.octave ?? .zero)))
    if let pIClass = PitchIntervalClass(rawValue: semitonesDiff) {
        return pIClass
    }
    print("Error deriving pitch interval class from notes!")
    return .zero
}

//assumes the notes are already spelled correctly
func intervalDiatonicSize(between note1: Note, and note2: Note) -> IntervalDiatonicSize {
    let absStepsAway = abs(note1.noteLetter.abstractTonalScaleDegree - note2.noteLetter.abstractTonalScaleDegree)
    let stepsAway = (absStepsAway + NoteLetter.allCases.count) % NoteLetter.allCases.count
    print(stepsAway)
    if stepsAway == 0 {
        return note1.octave == note2.octave ? IntervalDiatonicSize.unison : IntervalDiatonicSize.octave
    }
    for size in IntervalDiatonicSize.allCases {
        if size.numSteps == stepsAway { return size }
    }
    print("Error deriving interval's within-octave diatonic size")
    return IntervalDiatonicSize.unison
}

func interval(between note1: Note, and note2: Note) -> Interval {
    let intervalClass = pitchIntervalClass(between: note1, and: note2)
    let diatonicSize = intervalDiatonicSize(between: note1, and: note2)
    if let interval = Interval(intervalClass: intervalClass, size: diatonicSize) {
        return interval
    }
    for possibleComponent in intervalClass.possibleIntervalComponents {
        let possibleQuality = possibleComponent.quality
        if let interval = Interval(quality: possibleQuality, size: diatonicSize) {
            return interval
        }
    }
    return Interval(intervalClass: .zero, quality: .perfect, size: .unison)
}

