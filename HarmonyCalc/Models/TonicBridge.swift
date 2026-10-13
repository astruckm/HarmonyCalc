//
//  TonicBridge.swift
//  HarmonyCalc
//
//  Created by ASM on 6/25/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import Tonic

func pitchClass(from noteClass: NoteClass) -> PitchClass? {
    return PitchClass(rawValue: Int(noteClass.canonicalNote.pitch.pitchClass))
}

/// The summed accidental distance across all its tones.
func spellingComplexity(of chord: Chord) -> Int {
    return chord.noteClasses.reduce(0) { $0 + abs(Int($1.accidental.rawValue)) }
}

/// How many of a chord's tones are spelled against the collection's accidental direction —
/// flats when the collection uses sharps, or sharps when it uses flats.
func accidentalsAgainstDirection(of chord: Chord, usingSharps: Bool) -> Int {
    return chord.noteClasses.reduce(0) { count, noteClass in
        let accidental = Int(noteClass.accidental.rawValue)
        let isAgainstDirection = usingSharps ? accidental < 0 : accidental > 0
        return count + (isAgainstDirection ? 1 : 0)
    }
}

/// How many chord tones form an unbroken stack of thirds rising from the chord's root, where a "third" spans exactly one skipped letter name (C→E, B→D).
/// For example,  a fuller stack (m7 covers all 4 tones) scores higher than an added-note reading of the same pitches (a 6 chord breaks after 3).
/// A tone reached by a diminished or augmented third (A♯→C, E→G♯♯) counts slightly less than one reached by a major or minor third, so among equally full stacks the one built from cleaner thirds wins, without ever outranking a fuller stack.
func tertianThirdCount(of chord: Chord) -> Double {
    let rootLetter = chord.root.letter.rawValue
    let noteClassesByDistance = Dictionary(chord.noteClasses.map { (($0.letter.rawValue - rootLetter + 7) % 7, $0) },
                                           uniquingKeysWith: { first, _ in first })
    // Letter distances of a third-stack in order: root, 3rd, 5th, 7th, 9th, 11th, 13th.
    let stackDistances = [0, 2, 4, 6, 1, 3, 5]
    let alteredThirdWeight = 0.9
    var count = 0.0
    var previous: NoteClass?
    for distance in stackDistances {
        guard let noteClass = noteClassesByDistance[distance] else { break }
        if let previous = previous {
            let semitones = (Int(noteClass.canonicalNote.pitch.pitchClass) - Int(previous.canonicalNote.pitch.pitchClass) + 12) % 12
            count += (semitones == 3 || semitones == 4) ? 1 : alteredThirdWeight
        } else {
            count += 1
        }
        previous = noteClass
    }
    return count
}

enum TonalChordInversion: String, CaseIterable {
    case root = "Root"
    case first = "1st"
    case second = "2nd"
    case third = "3rd"
    case fourth = "4th"
    case fifth = "5th"
    case sixth = "6th"
    
    init(inversionIndex: Int) {
        let index = inversionIndex % TonalChordInversion.allCases.count
        self = TonalChordInversion.allCases[index]
    }
}
