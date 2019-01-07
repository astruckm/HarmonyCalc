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
    //some dictionary here with scale degree interval to possible semitone intervals.
    //maybe need a scale degree enum?
    
    //true is sharps, false is flats
    func collectionShouldUseSharps(_ pitchCollection: [PitchClass]) -> Bool {
        //1. Check pitchCollection with all sharps to make sure has no augmented or diminished 2nds, 3rds, no diminshed 4ths
        //2. Check with all flats
        //subfunctions to check for suboptimal interval spellings: find NoteLetter of each pc based on if it's in sharps or flats.
        
        return true
    }
    
    //check each combination of 2 pitch classes for subintervals.
    //assumes there are no duplicate notes
    func pairsWithSuboptimalSpellings(among notes: [Note]) -> [(Note, Note)] {
        var subOptimallySpelledPairs: [(Note, Note)] = []
        for noteIndex in 0..<notes.count {
            guard noteIndex < notes.count - 1 else { continue }
            for pairNoteIndex in noteIndex..<notes.count {
                let note = notes[noteIndex]
                let pairNote = notes[pairNoteIndex]
                if !note.pitchClass.isBlackKey && !pairNote.pitchClass.isBlackKey { continue }
                if pairIsSpelledSuboptimally((note, pairNote)) { subOptimallySpelledPairs.append((note, pairNote)) }
            }
        }
        return subOptimallySpelledPairs
    }
    
    private func pairIsSpelledSuboptimally(_ pair: (Note, Note)) -> Bool {
        let rawStepsAway = abs(pair.0.noteLetter.abstractTonalScaleDegree - pair.1.noteLetter.abstractTonalScaleDegree)
        let minimumStepsAway = rawStepsAway <= 3 ? rawStepsAway : 7 - rawStepsAway
        let semitonesAway = abs(pair.0.pitchClass.rawValue - pair.1.pitchClass.rawValue)
        let intervalClass = semitonesAway <= 6 ? semitonesAway : (12 - semitonesAway)
        
        switch minimumStepsAway {
        case 0: return true
        case 1:
            return intervalClass >= 1 || intervalClass <= 2
        case 2:
            if intervalClass < 3 || intervalClass > 4 { return true }
        case 3:
            if intervalClass < 5 || intervalClass > 6 { return true }
        default:
            print("Error in calculates steps pair is apart")
            return false
        }
        return false
    }

}



/*

//reconcile .possibleSpellings with possible NoteLetter
func bestEnharmonicSpelling(of pitchCollection: [PitchClass]) -> [(PitchClass, NoteLetter)] {
    //a. prefer to have each PitchClass have a different Letter Name if possible
    
    
    let possibleSpellings = pitchCollection.map({$0.possibleSpellings})
    let possibleLetterNames = pitchCollection.map({$0.possibleLetterNames})
    
    //b. prefer to have uniformity of flats or sharps if possible
    //c. prefer to not have diminished or augmented intervals if possible (#1. & #2 will help with this--so just check for B-Db, D#-F and any B#, Cb, E#, Fbs)

    return []
}

//helpers
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


    
