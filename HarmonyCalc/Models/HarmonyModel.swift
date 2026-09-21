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

    func analyze(_ notes: [Note]) -> HarmonyAnalysis {
        let pitchClasses = Array(Set(notes.map { $0.pitchClass })).sorted(by: <)
        guard pitchClasses.count >= 2 else { return .empty }

        let normalForm = self.normalForm(of: pitchClasses)
        let primeForm = self.primeForm(ofCollectionInNormalForm: normalForm)
        let intervalVector = self.intervalVector(of: pitchClasses)
        let forteName = ForteTable.name(forPrimeForm: primeForm)
        let (primary, alternatives) = rankedCandidates(from: notes)

        return HarmonyAnalysis(primary: primary,
                               alternatives: alternatives,
                               normalForm: normalForm,
                               primeForm: primeForm,
                               intervalVector: intervalVector,
                               forteName: forteName)
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

    func intervalVector(of pitchCollection: [PitchClass]) -> [Int] {
        return PitchClassSet(pitchCollection.map { $0.rawValue }).intervalVector
    }

    private func rankedCandidates(from notes: [Note]) -> (primary: ChordCandidate?, alternatives: [ChordCandidate]) {
        guard notes.count >= 2 else { return (nil, []) }
        let pitchClasses = notes.map { $0.pitchClass.rawValue }
        guard Set(pitchClasses).count >= 2 else { return (nil, []) }
        let mask = HarmonyModel.pitchClassMask(of: pitchClasses)
        guard let tonicChords = HarmonyModel.chordsByPitchClassMask[mask], !tonicChords.isEmpty else { return (nil, []) }
        guard let bassValue = notes.map({ $0.midiNoteNumber }).min() else { return (nil, []) }
        let bassPitchClass = bassValue % 12

        var deduped: [Chord] = []
        for chord in tonicChords {
            guard let rootPC = pitchClass(from: chord.root) else { continue }
            if let existing = deduped.firstIndex(where: {
                $0.type == chord.type && pitchClass(from: $0.root) == rootPC
            }) {
                if spellingComplexity(of: chord.root) < spellingComplexity(of: deduped[existing].root) {
                    deduped[existing] = chord
                }
            } else {
                deduped.append(chord)
            }
        }

        // Drop degenerate over-spellings before ranking. Tonic's vocabulary includes altered types whose upper extensions are enharmonically identical to lower chord tones — e.g. ø7(♭5)(♯9)(♯11) where ♯9 = ♭3 and ♯11 = ♭7 as pitch classes.
        let distinctPitchClasses = Set(pitchClasses).count
        let scored = deduped.compactMap { chord -> (chord: Chord, rootPC: PitchClass, thirdsCount: Int, spellingComplexity: Int)? in
            guard let rootPC = pitchClass(from: chord.root) else { return nil }
            return (chord, rootPC, tertianThirdCount(of: chord), spellingComplexity(of: chord.root))
        }
        let clean = scored.filter { $0.chord.noteClasses.count == distinctPitchClasses }
        let usable = clean.isEmpty ? scored : clean
        guard !usable.isEmpty else { return (nil, []) }

        // Rank the surviving readings: first by fullest stack of thirds first — so C-E-G-A reads as Am7 (a four-note stack) rather than C6 (a triad plus an added sixth) — then the reading with the bass as root; then simpler spelling; then the table's own order.
        let ranked = usable.enumerated().sorted { lhs, rhs in
            let (l, r) = (lhs.element, rhs.element)
            if l.thirdsCount != r.thirdsCount { return l.thirdsCount > r.thirdsCount }
            let lBass = l.rootPC.rawValue == bassPitchClass
            let rBass = r.rootPC.rawValue == bassPitchClass
            if lBass != rBass { return lBass }
            if l.spellingComplexity != r.spellingComplexity { return l.spellingComplexity < r.spellingComplexity }
            return lhs.offset < rhs.offset
        }.map { $0.element }

        let candidates: [ChordCandidate] = ranked.map { scored in
            let chordPitchClasses = scored.chord.noteClasses.map { Int($0.canonicalNote.pitch.pitchClass) }
            let inversionIndex = chordPitchClasses.firstIndex(of: bassPitchClass) ?? 0
            return ChordCandidate(root: scored.rootPC,
                                  rootSpelling: scored.chord.root.description,
                                  quality: scored.chord.type.description,
                                  inversion: TonalChordInversion(inversionIndex: inversionIndex).rawValue)
        }

        guard let primary = candidates.first else { return (nil, []) }
        return (primary, Array(candidates.dropFirst()))
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
