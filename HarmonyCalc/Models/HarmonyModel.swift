//
//  NoteModel.swift
//  HarmonyCalc
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation
import Tonic

public struct HarmonyModel {
    //***************************************************
    //MARK: Properties
    //***************************************************
    
    let maxNotesInCollection: Int
    var maxNotes: Int { return maxNotesInCollection % 12 }

    // Index tonal chords once by absolute pitch-class set for O(1) lookup.
    private static let chordsByPitchClassMask: [Int: [Chord]] = {
        let accidentals: [Accidental] = Accidental.allCases
        var table: [Int: [Chord]] = [:]
        for type in ChordType.allCases {
            for accidental in accidentals {
                for letter in Letter.allCases {
                    let chord = Chord(NoteClass(letter, accidental: accidental), type: type)
                    guard chord.noteClasses.count > type.intervals.count else { continue }
                    let mask = HarmonyModel.pitchClassMask(of: chord.noteClasses.map { Int($0.canonicalNote.pitch.pitchClass) })
                    table[mask, default: []].append(chord)
                }
            }
        }
        // Prefer the simplest chord type when several match the same pitch-class set.
        let typeRank = Dictionary(uniqueKeysWithValues: ChordType.allCases.enumerated().map { ($1, $0) })
        for mask in table.keys {
            table[mask]?.sort { (typeRank[$0.type] ?? 0, $0.root.intValue) < (typeRank[$1.type] ?? 0, $1.root.intValue) }
        }
        return table
    }()

    init(maxNotesInCollection: Int) {
        self.maxNotesInCollection = maxNotesInCollection
        _ = HarmonyModel.chordsByPitchClassMask
    }
    
    //**********************************************************
    //MARK: Set Theory
    //Using Joseph N. Straus' "Introduction to Post-Tonal Theory"
    //**********************************************************
    func normalForm(of pitchCollection: [PitchClass]) -> [PitchClass] {
        let normalForm = PitchClassSet(pitchCollection.map { $0.rawValue }).normalForm
        return normalForm.compactMap { PitchClass(rawValue: $0) }
    }
    
    func primeForm(ofCollectionInNormalForm pitchCollection: [PitchClass]) -> [Int] {
        return PitchClassSet(pitchCollection.map { $0.rawValue }).primeForm
    }
    
    
    //**********************************************************
    //MARK: Tonal collections
    //**********************************************************

    func chord(from notes: [Note]) -> (root: PitchClass, quality: String, inversion: String)? {
        guard notes.count >= 2 else { return nil }
        let pitchClasses = notes.map { $0.pitchClass.rawValue }
        guard Set(pitchClasses).count >= 2 else { return nil }
        let mask = HarmonyModel.pitchClassMask(of: pitchClasses)
        guard let candidates = HarmonyModel.chordsByPitchClassMask[mask], !candidates.isEmpty else { return nil }
        guard let bassValue = notes.map({ $0.midiNoteNumber }).min() else { return nil }
        let bassPitchClass = bassValue % 12
        let chosen = candidates.first { Int($0.root.canonicalNote.pitch.pitchClass) == bassPitchClass } ?? candidates[0]
        guard let root = pitchClass(from: chosen.root) else { return nil }
        let chordPitchClasses = chosen.noteClasses.map { Int($0.canonicalNote.pitch.pitchClass) }
        let inversionIndex = chordPitchClasses.firstIndex(of: bassPitchClass) ?? 0
        let inversion = TonalChordInversion(inversionIndex: inversionIndex).rawValue
        return (root, chosen.type.description, inversion)
    }

    private static func pitchClassMask(of pitchClasses: [Int]) -> Int {
        return pitchClasses.reduce(0) { $0 | (1 << $1) }
    }
    
}
