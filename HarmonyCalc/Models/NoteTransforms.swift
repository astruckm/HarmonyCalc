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

/// Translate a raw note value into a PitchClass
/// - Parameter keyValue: A raw note value (e.g. a MIDI note number)
/// - Returns: The pitch class derived from the value's mod 12
func putInRange(keyValue: Int) -> PitchClass {
    let numNotesInOctave = PitchClass.allCases.count
    if keyValue < numNotesInOctave && keyValue >= 0 {
        return PitchClass.allCases[keyValue]
    }
    
    var newPitchValue = keyValue % numNotesInOctave
    if newPitchValue < 0 { newPitchValue += numNotesInOctave }
    return PitchClass.allCases[newPitchValue]
}

/// Get the Int diff between two notes
/// - Parameters:
///   - noteOne: The first note, the order between these two doesn't matter
///   - noteTwo: The second note, the order between these two doesn't matter
/// - Returns: The raw integer interval between the two notes
func intervalNumberBetweenNotes(noteOne: Note, noteTwo: Note) -> Int {
    let rawInterval = abs(noteOne.midiNoteNumber - noteTwo.midiNoteNumber)
    //Put notes in same octave
    return rawInterval % PitchClass.allCases.count
}
