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
    var maxNotes: Int { return min(maxNotesInCollection, 12) }

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

    func analyze(_ notes: [Note], usingSharps: Bool = true) -> HarmonyAnalysis {
        let pitchClasses = notes.pitchClasses
        guard pitchClasses.count >= 2 else { return .empty }

        let (primary, alternatives) = rankedCandidates(from: notes, pitchClasses: pitchClasses, usingSharps: usingSharps)
        let pitchClassSet = PitchClassSet(pitchClasses.map { $0.rawValue })
        let normalForm = pitchClassSet.normalForm.compactMap { PitchClass(rawValue: $0) }
        let primeForm = pitchClassSet.primeForm
        let intervalVector = pitchClassSet.intervalVector
        let forteName = ForteTable.name(forPrimeForm: primeForm)

        return HarmonyAnalysis(primary: primary,
                               alternatives: alternatives,
                               normalForm: normalForm,
                               primeForm: primeForm,
                               intervalVector: intervalVector,
                               forteName: forteName)
    }

    /// - Parameter pitchClasses: The notes' distinct pitch classes; `analyze` guarantees there are at least 2.
    private func rankedCandidates(from notes: [Note], pitchClasses: [PitchClass], usingSharps: Bool) -> (primary: ChordCandidate?, alternatives: [ChordCandidate]) {
        guard notes.count >= 2 else { return (nil, []) }
        let mask = HarmonyModel.pitchClassMask(of: pitchClasses.map { $0.rawValue })
        guard let tonicChords = HarmonyModel.chordsByPitchClassMask[mask], !tonicChords.isEmpty else { return (nil, []) }
        guard let bassPitchClass = notes.min()?.pitchClass else { return (nil, []) }

        typealias ScoredChord = (chord: Chord, rootPC: PitchClass, thirdsCount: Int, spellingWeight: Int, offDirection: Int)
        let allSpellings = tonicChords.compactMap { chord -> ScoredChord? in
            guard let rootPC = pitchClass(from: chord.root) else { return nil }
            return (chord, rootPC, tertianThirdCount(of: chord), spellingComplexity(of: chord), accidentalsAgainstDirection(of: chord, usingSharps: usingSharps))
        }

        // Among enharmonic spellings of the same root, keep the one that is simplest overall and best matches the collection's accidental direction (sharps vs flats).
        var scored: [ScoredChord] = []
        for spelling in allSpellings {
            if let existing = scored.firstIndex(where: { $0.chord.type == spelling.chord.type && $0.rootPC == spelling.rootPC }) {
                if (spelling.spellingWeight, spelling.offDirection) < (scored[existing].spellingWeight, scored[existing].offDirection) {
                    scored[existing] = spelling
                }
            } else {
                scored.append(spelling)
            }
        }

        // Drop degenerate over-spellings before ranking. Tonic's vocabulary includes altered types whose upper extensions are enharmonically identical to lower chord tones — e.g. ø7(♭5)(♯9)(♯11) where ♯9 = ♭3 and ♯11 = ♭7 as pitch classes.
        let distinctPitchClasses = Set(pitchClasses).count
        let clean = scored.filter { $0.chord.noteClasses.count == distinctPitchClasses }
        let usable = clean.isEmpty ? scored : clean
        guard !usable.isEmpty else { return (nil, []) }

        // Rank the candidates by, in order by:
        // 1. Fullest stack of thirds
        // 2. The simplest overall spelling
        // 3. The collection's accidental direction
        // 4. The reading on the bass
        // 5. The table's own order.
        let ranked = usable.enumerated().sorted { lhs, rhs in
            let (l, r) = (lhs.element, rhs.element)
            if l.thirdsCount != r.thirdsCount { return l.thirdsCount > r.thirdsCount }
            if l.spellingWeight != r.spellingWeight { return l.spellingWeight < r.spellingWeight }
            if l.offDirection != r.offDirection { return l.offDirection < r.offDirection }
            let lBass = l.rootPC == bassPitchClass
            let rBass = r.rootPC == bassPitchClass
            if lBass != rBass { return lBass }
            return lhs.offset < rhs.offset
        }.map { $0.element }

        let candidates: [ChordCandidate] = ranked.map { scored in
            let chordPitchClasses = scored.chord.noteClasses.map { Int($0.canonicalNote.pitch.pitchClass) }
            let inversionIndex = chordPitchClasses.firstIndex(of: bassPitchClass.rawValue) ?? 0
            return ChordCandidate(root: scored.rootPC,
                                  rootSpelling: scored.chord.root.description,
                                  quality: scored.chord.type.description,
                                  inversion: TonalChordInversion(inversionIndex: inversionIndex).rawValue)
        }

        guard let primary = candidates.first else { return (nil, []) }
        return (primary, Array(candidates.dropFirst()))
    }

    private static func pitchClassMask(of pitchClasses: [Int]) -> Int {
        return pitchClasses.reduce(0) { $0 | (1 << $1) }
    }
}
