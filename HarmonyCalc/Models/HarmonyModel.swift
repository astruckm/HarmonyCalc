//
//  NoteModel.swift
//  HarmonyCalc
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//
//  This struct is the brain of the calculator, taking in pitch classes and outputting tonal and atonal collections

//TODO: break this up into smaller files: atonal harmony, tonal harmony, some all-harmonies class that stores outputs and converts everything to strings for VC (takes some NoteVC code too)

import Foundation

public struct HarmonyModel {
    //***************************************************
    //MARK: Properties
    //***************************************************
    
    let maxNotesInCollection: Int
    var maxNotes: Int { return maxNotesInCollection % 12 }
            
    // Placeholder values for ambiguous chords: fully dim, aug, sus
    //The index here = ([PitchClass].count of the chord) - intLiteralOfInversionName
    //I.e. how many index "steps" to go through to get to the root
    private let chordSymbolsRootInNormalFormByIntervals: [String: (chordSymbol: String, rootIndex: Int)] = [
        "[4, 3]": (TonalChordType.major.rawValue, 0),
        "[3, 4]": (TonalChordType.minor.rawValue, 0),
        "[3, 3]": (TonalChordType.diminished.rawValue, 0),
        "[4, 4]": (TonalChordType.augmented.rawValue, 0),
        "[2, 5]": (TonalChordType.suspended.rawValue, 2),
        
        "[3, 3, 2]": (TonalChordType.dominantSeven.rawValue, 3),
        "[3, 2, 3]": (TonalChordType.minorSeven.rawValue, 2),
        "[1, 4, 3]": (TonalChordType.majorSeven.rawValue, 1),
        "[3, 3, 3]": (TonalChordType.diminishedSeven.rawValue, 0),
        "[2, 3, 3]": (TonalChordType.halfDiminishedSeven.rawValue, 1),
        "[2, 2, 4]": (TonalChordType.augmentedSeven.rawValue, 2),
        "[3, 1, 4]": (TonalChordType.augmentedMajorSeven.rawValue, 2),
        
        "[3, 2, 2, 2]": (TonalChordType.dominantNine.rawValue, 2),
        "[1, 2, 2, 3]": (TonalChordType.majorNine.rawValue, 1),
        "[3, 2, 2, 1]": (TonalChordType.minorNine.rawValue, 2),
        "[2, 1, 3, 3]": (TonalChordType.flatNine.rawValue, 1),
        "[3, 3, 2, 1]": (TonalChordType.sharpNine.rawValue, 3),
        
        "[2, 2, 2, 1, 2]": (TonalChordType.eleven.rawValue, 1),
        "[1, 2, 2, 1, 2]": (TonalChordType.majorEleven.rawValue, 1),
        "[2, 2, 1, 2, 2]": (TonalChordType.minorEleven.rawValue, 1),
        "[2, 2, 2, 2, 1]": (TonalChordType.sharpEleven.rawValue, 1),
        
        "[2, 2, 2, 2, 1, 2]": (TonalChordType.sharpThirteen.rawValue, 2),
        "[1, 2, 2, 1, 2, 2]": (TonalChordType.thirteen.rawValue, 5)
    ]
    
    
    //**********************************************************
    //MARK: Set Theory
    //Using Joseph N. Straus' "Introduction to Post-Tonal Theory"
    //**********************************************************
    private func getIntervalClass(_ pitchIntervalClass: PitchIntervalClass) -> Int {
        let pIC = pitchIntervalClass.rawValue
        return pIC <= 6 ? pIC : (12 - pIC)
    }
    
    mutating func normalForm(of pitchCollection: [PitchClass]) ->  [PitchClass] {
        let pcNoDuplicates = Array(Set(pitchCollection))
        guard pitchCollection.count >= 2 else { return [] }
        let pitchCollectionInversions = allInversions(of: pcNoDuplicates)
        
        //Find inversion(s) with shortest first to last distance
        let shortestCollections = findShortestCollections(of: pitchCollectionInversions)
        
        if shortestCollections.count == 1 {
            return shortestCollections[0]
        }
        
        //Find if one collection is shortest, checking span between second-to-last, then third-to-last, etc.
        let shortestCollection = findShortestCollection(of: shortestCollections)
        
        //Since pitchCollectionInversions should already be sorted to have lowest pitch class inversion first by allInversions(notes:), return first if still a tie (e.g. augmented or fully diminished)
        return shortestCollection ?? pitchCollectionInversions[0]
    }
    
    //Normal form helper funcs
    private mutating func findShortestCollections(of pitchCollectionInversions: [[PitchClass]]) -> [[PitchClass]] {
        var shortestDistance = 12 ///Storage variable initialized with value guaranteed to be larger than first intervalSpan
        
        var shortestCollections = [[PitchClass]]()
        for collection in pitchCollectionInversions {
            ///Put top key (keyOne) an octave above bottom key (keyTwo) to properly account for span
            let intervalSpan = intervalNumberBetweenKeys(keyOne: (collection[collection.count-1], Octave.one), keyTwo: (collection[0], Octave.zero))
            if intervalSpan < shortestDistance {
                shortestCollections = [[PitchClass]]()
                shortestCollections.append(collection)
                shortestDistance = intervalSpan
            } else if intervalSpan == shortestDistance {
                shortestCollections.append(collection)
            }
        }
        return shortestCollections
    }
    
    private mutating func findShortestCollection(of shortestCollections: [[PitchClass]]) -> [PitchClass]? {
        var shortestDistance = 12 ///Storage variable initialized with value guaranteed to be larger than first intervalSpan
        
        var shortestCollection = [[PitchClass]]()
        for loopIndex in 0...(shortestCollections[0].count-1) {
            for collection in shortestCollections {
                let intervalSpan = intervalNumberBetweenKeys(keyOne: (collection[collection.count-1-loopIndex], Octave.one), keyTwo: (collection[0], Octave.zero))
                if intervalSpan < shortestDistance {
                    shortestCollection = [[PitchClass]]()
                    shortestCollection.append(collection)
                    shortestDistance = intervalSpan
                } else if intervalSpan == shortestDistance {
                    shortestCollection.append(collection)
                }
            }
            if shortestCollection.count == 1 {
                return shortestCollection[0]
            }
        }
        
        return nil
    }
    
    //Outputs Ints because this is the most reduced kind of set
    mutating func primeForm(ofCollectionInNormalForm pitchCollection: [PitchClass]) -> [Int] {
        guard pitchCollection.count >= 2 else { return [] }
        
        let transposedToZero = pitchCollection.map{putInRange(keyValue: $0.rawValue-pitchCollection[0].rawValue)}
        let inversion = pitchCollectionInversion(of: pitchCollection)
        
        //if inversion and uninverted are equally packed left
        return packToLeft(originalCollection: transposedToZero, inversion: inversion).map{$0.rawValue}
    }
    
    //Helper func for Prime form func, so transposes to zero
    private func pitchCollectionInversion(of set: [PitchClass]) -> [PitchClass] {
        let rawInvertedValues = set.map{ 12 - $0.rawValue }
        let invertedValues = rawInvertedValues.map{putInRange(keyValue: $0)}
        let lastPCRawValue = invertedValues[(invertedValues.count-1)].rawValue
        var invertedValuesTransposedToZero = invertedValues.map { element -> PitchClass in
            let intValue = element.rawValue - lastPCRawValue
            if intValue < 0 {
                let intPCValue = putInRange(keyValue: intValue)
                return intPCValue
            }
            if let pcValue = PitchClass(rawValue: intValue) {
                return pcValue
            } else {
                print("Error: inversion not executed correctly")
                return element
            }
        }
        invertedValuesTransposedToZero.sort(by: <)
        return invertedValuesTransposedToZero
    }
    
    private func packToLeft(originalCollection transposedToZero: [PitchClass], inversion: [PitchClass]) -> [PitchClass] {
        //Use Forte method, packed to left
        var counter = 1
        while counter < transposedToZero.count {
            if transposedToZero[counter] < inversion[counter] {
                return transposedToZero
            } else if transposedToZero[counter] > inversion[counter] {
                return inversion
            }
            counter += 1
        }
        
        //if inversion and uninverted are equally packed left
        return transposedToZero
        
    }
    
    
    //**********************************************************
    //MARK: Tonal collections
    //**********************************************************
    
    //Helper func, use on collections that are in normal form already
    private mutating func intervalsBetweenPitches(pitchCollection: [PitchClass]) -> [Int] {
        guard pitchCollection.count >= 2 else { return [] }
        var intervalCollection: [Int] = []
        for index in 0..<pitchCollection.count-1 {
            let rawInterval = pitchCollection[index+1].rawValue - pitchCollection[index].rawValue
            let interval = rawInterval >= 0 ? rawInterval : (rawInterval+12)
            intervalCollection.append(interval)
        }
        return intervalCollection
    }
    
    mutating func getChordIdentity(of pitchCollection: [PitchClass]) -> (root: PitchClass, chordQuality: TonalChordType)? {
        guard pitchCollection.count >= 2 else { return nil }
        let pcNoDuplicates = Array(Set(pitchCollection))
        let pcNormalForm = normalForm(of: pcNoDuplicates)
        let intervals = intervalsBetweenPitches(pitchCollection: pcNormalForm)
        if let chordSymbolIndex = chordSymbolsRootInNormalFormByIntervals[intervals.description],
           let tonalChordType = TonalChordType(rawValue: chordSymbolIndex.chordSymbol),
           chordSymbolIndex.rootIndex < pcNormalForm.count
           {
            let rootPitchClass = pcNormalForm[chordSymbolIndex.rootIndex]
            return (rootPitchClass, tonalChordType)
        }
//        if let chordType = tonalChordIntervalsInNormalForm[intervals.description] {
//            if let rootIndex = tonalChordRootIndexInNormalForm[chordType], let tonalChordType = TonalChordType(rawValue: chordType)  {
//                let rootPitchClass = pcNormalForm[rootIndex!]
//                return (rootPitchClass, tonalChordType)
//            }
//        }
        return nil
    }
    
    mutating func getChordInversion(of pitchCollection: [(PitchClass, Octave)]) -> String? {
        guard pitchCollection.count >= 2 else { return nil }
        let pitchClasses: [PitchClass] = pitchCollection.map { $0.0 }
        if let bassNoteKeyValue = pitchCollection.map({ pc in keyValue(pitch: pc) }).min() {
            let bassNote = putInRange(keyValue: bassNoteKeyValue)
            let pcNormalForm = normalForm(of: pitchClasses)
            let intervals = intervalsBetweenPitches(pitchCollection: pcNormalForm)
            
            // Find where bassNote's index is in normal form
            if let bassNoteIndex = pcNormalForm.firstIndex(of: bassNote),
               let chordSymbolIndex = chordSymbolsRootInNormalFormByIntervals[intervals.description] {
                let rootIndex = chordSymbolIndex.rootIndex
                var distanceFromRoot = Int(bassNoteIndex) - rootIndex
                if distanceFromRoot < 0 { distanceFromRoot += pcNormalForm.count }
                switch distanceFromRoot {
                case 0: return "Root"
                case 1: return "1st"
                case 2: return "2nd"
                case 3: return "3rd"
                default: return nil
                }
            }
        }
        
        return nil
    }
    
    //TODO: Chord (i.e. root + type/quality), inversion (i.e. root's index), normal form, prime form should all be called by func with massive output that is tuple of every chord form you would want, as Strings. ViewController shouldn't have to type convert.
    mutating func getHarmonyValuesForDisplay(of pitchCollection: [(PitchClass, Octave)]) -> (normalForm: String, primeForm: String, chordIdentity: String?, chordInversion: String?) {
        guard pitchCollection.count >= 2 else { return ("", "", nil, nil) }
        //        let normalForm = self.normalForm(of: pitchCollection.map { $0.0 } )
        
        //2. Use it to get prime form and chord type
        //3. Use chord type to get inversion
        //4. Convert everything to Strings
        
        return ("", "", nil, nil)
    }
}
