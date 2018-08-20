//
//  Note Transforms.swift
//  Chord Calculator
//
//  Created by ASM on 8/16/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

//input notes in a chord, output all possible inversions
func allInversions(of collection: [PitchClass]) -> [[(PitchClass)]] {
    var allInversionsOfCollection = [[PitchClass]]()
    var inversion = collection.sorted(by: <)
    for _ in 0...(collection.count-1) {
        allInversionsOfCollection.append(inversion)
        let firstNote = inversion.remove(at: 0)
        inversion.append(firstNote)
    }
    return allInversionsOfCollection
}

//Int value for a key
func keyValue(pitch: (PitchClass, Octave)) -> Int {
    return pitch.0.rawValue + (pitch.1.rawValue * 12)
}

//Make any Int the corresponding PitchClass
func putInRange(keyValue: Int) -> PitchClass {
    if keyValue < 12 && keyValue >= 0 {
        return PitchClass(rawValue: keyValue)!
    }
    
    var newPitchValue = keyValue % 12
    if newPitchValue < 0 { newPitchValue += 12 }
    return PitchClass(rawValue: newPitchValue)!
}

func intervalNumberBetweenKeys(keyOne: (PitchClass, Octave), keyTwo: (PitchClass, Octave)) -> Int {
    var rawInterval = abs(keyValue(pitch: keyOne) - keyValue(pitch: keyTwo))
    //Put keys in same octave
    rawInterval %= 12
    return rawInterval
}
