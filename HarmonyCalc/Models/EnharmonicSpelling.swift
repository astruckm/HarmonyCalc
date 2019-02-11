//
//  EnharmonicSpelling.swift
//  Chord Calculator
//
//  Created by ASM on 4/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

//This is irrespective of major/minor key
struct BestEnharmonicSpelling {
    //true is sharps, false is flats
    func collectionShouldUseSharps(_ pitchCollection: [PitchClass]) -> Bool {
        let allSharps: [Note] = pitchCollection.compactMap{Note(pitchClass: $0, noteLetter: $0.possibleLetterNames[0], octave: nil)}
        let allFlats: [Note] = pitchCollection.compactMap{Note(pitchClass: $0, noteLetter: $0.isBlackKey ? $0.possibleLetterNames[1] : $0.possibleLetterNames[0], octave: nil)}
        print("all sharps: \(pairsWithSuboptimalSpellings(among: allSharps).count)")
        print("all flats: \(pairsWithSuboptimalSpellings(among: allFlats).count)")
        return pairsWithSuboptimalSpellings(among: allSharps).count <= pairsWithSuboptimalSpellings(among: allFlats).count
    }
    
    //Compares each possible pair, assumes there are no duplicate notes
    func pairsWithSuboptimalSpellings(among notes: [Note]) -> [(Note, Note)] {
        guard notes.count >= 2 else { return [] }
        var subOptimallySpelledPairs: [(Note, Note)] = []
        for noteIndex in 0..<(notes.count-1) {
            for pairNoteIndex in (noteIndex+1)..<notes.count {
                let note = notes[noteIndex]
                let pairNote = notes[pairNoteIndex]
                if !note.pitchClass.isBlackKey && !pairNote.pitchClass.isBlackKey { continue }
                if pairIsSpelledSuboptimally((note, pairNote)) { subOptimallySpelledPairs.append((note, pairNote)) }
            }
        }
        print("sub optimally spelled pairs: \(subOptimallySpelledPairs)")
        return subOptimallySpelledPairs
    }
    
    func pairIsSpelledSuboptimally(_ pair: (Note, Note)) -> Bool {
        let rawStepsAway = abs(pair.0.noteLetter.abstractTonalScaleDegree - pair.1.noteLetter.abstractTonalScaleDegree)
        let minimumStepsAway = rawStepsAway <= 3 ? rawStepsAway : 7 - rawStepsAway ///i.e. how close the two notes COULD be
        print("minimum steps away: \(minimumStepsAway)")
        let semitonesAway = abs(pair.0.pitchClass.rawValue - pair.1.pitchClass.rawValue)
        let intervalClass = semitonesAway <= 6 ? semitonesAway : (12 - semitonesAway)
        print("interval class: \(intervalClass)")
        
        switch minimumStepsAway {
        case 0: return true
        case 1:
            return intervalClass < 1 || intervalClass > 2 ///2nds should be 1 or 2 semitones
        case 2:
            return intervalClass < 3 || intervalClass > 4 ///3rds, 3 or 4 semitones
        case 3:
            return intervalClass < 5 || intervalClass > 6 ///4ths, 5 or 6 semitones
        default:
            print("Error in calculating steps pair is apart")
            return false
        }
    }

}



/*

//reconcile .possibleSpellings with possible NoteLetter
func bestEnharmonicSpelling(of pitchCollection: [PitchClass]) -> [(PitchClass, NoteLetter)] {
    //a. prefer to have each PitchClass have a different Letter Name if possible
    
    //b. prefer to have uniformity of flats or sharps if possible
    //c. prefer to not have diminished or augmented intervals if possible (#1. & #2 will help with this--so just check for B-Db, D#-F and any B#, Cb, E#, Fbs)

    return []
}

func bestLetterNames(of pitchCollection: [PitchClass]) -> [(PitchClass, NoteLetter)] {
    let letterNamesInPC = Set<NoteLetter>()
    //if length of letterNamesInPC is same as pitchCollection, can skip this step
    let initialLetterNames: [NoteLetter] = pitchCollection.map { $0.possibleLetterNames.first! }
    var differentLetterNamePC: [PitchClass] = []
    for pitchClass in pitchCollection {
        
    }

    
    return []
}

*/


    
