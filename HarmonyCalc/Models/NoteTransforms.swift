//
//  Note Transforms.swift
//  HarmonyCalc
//
//  Created by ASM on 8/16/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

/// Get all possible inversions of a collection of pitch classes
/// - Parameter collection: Pitch classes in a chord
/// - Returns: An array of arrays of all possible inversion
func allInversions(of collection: [PitchClass]) -> [[(PitchClass)]] {
    guard !collection.isEmpty else { return [] }
    var allInversionsOfCollection = [[PitchClass]]()
    var inversion = collection.sorted(by: <)
    for _ in 0..<collection.count {
        allInversionsOfCollection.append(inversion)
        let firstNote = inversion.remove(at: 0)
        inversion.append(firstNote)
    }
    return allInversionsOfCollection
}

/// Get abstract Int value for a key on the piano, starting from 0 for lowest C possible/known. Like a MIDI note number.
/// - Parameter key: The pressed key (an Octave + PitchClass)
/// - Returns: The Int value
func keyValue(_ key: PianoKey) -> Int {
    return key.pitchClass.rawValue + (key.octave.rawValue * PitchClass.allCases.count)
}

/// Translate a raw note number into a PitchClass
/// - Parameter keyValue: A raw note number derived from keyValue(_: )
/// - Returns: The pitch class derived from keyValue's mod 12 value
func putInRange(keyValue: Int) -> PitchClass {
    let numNotesInOctave = PitchClass.allCases.count
    if keyValue < numNotesInOctave && keyValue >= 0 {
        return PitchClass.allCases[keyValue]
    }
    
    var newPitchValue = keyValue % numNotesInOctave
    if newPitchValue < 0 { newPitchValue += numNotesInOctave }
    return PitchClass.allCases[newPitchValue]
}

/// Get the Int diff between keys on a piano
/// - Parameters:
///   - keyOne: The first key, the order between these two doesn't matter
///   - keyTwo: The second key, the order between these two doesn't matter
/// - Returns: The raw integer interval between the two keys
func intervalNumberBetweenKeys(keyOne: PianoKey, keyTwo: PianoKey) -> Int {
    let rawInterval = abs(keyValue(keyOne) - keyValue(keyTwo))
    //Put keys in same octave
    return rawInterval % PitchClass.allCases.count
}
