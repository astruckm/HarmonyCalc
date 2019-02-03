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

//Abstract Int value for a key, starting from 0 for lowest C possible/known
//TODO: add func for MIDI note number
func keyValue(pitch: PianoKey) -> Int {
    return pitch.pitchClass.rawValue + (pitch.octave.rawValue * PitchClass.allCases.count)
}

//Make any Int the corresponding PitchClass
func putInRange(keyValue: Int) -> PitchClass {
    let numNotesInOctave = PitchClass.allCases.count
    if keyValue < numNotesInOctave && keyValue >= 0 {
        return PitchClass(rawValue: keyValue)!
    }
    
    var newPitchValue = keyValue % numNotesInOctave
    if newPitchValue < 0 { newPitchValue += numNotesInOctave }
    return PitchClass(rawValue: newPitchValue)!
}

func intervalNumberBetweenKeys(keyOne: PianoKey, keyTwo: PianoKey) -> Int {
    let rawInterval = abs(keyValue(pitch: keyOne) - keyValue(pitch: keyTwo))
    //Put keys in same octave
    return rawInterval % PitchClass.allCases.count
}
