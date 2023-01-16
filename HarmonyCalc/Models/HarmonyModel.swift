//
//  NoteModel.swift
//  HarmonyCalc
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//
//  This struct is the brain of the calculator, taking in pitch classes and outputting tonal and atonal collections

import Foundation

public struct HarmonyModel {
    //***************************************************
    //MARK: Properties
    //***************************************************
    
    let maxNotesInCollection: Int
    var maxNotes: Int { return maxNotesInCollection % 12 }
    var allTonalChordsByZeroBasedNormalForm: [[Int]: TonalChordType] {
        return Dictionary(uniqueKeysWithValues: TonalChordType.allCases.map { ($0.zeroBasedNormalForm, $0) })
    }
    
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
    
    mutating func getChordIdentity(of pitchCollection: [PitchClass]) -> (root: PitchClass, chordQuality: TonalChordType)? {
        guard pitchCollection.count >= 2 else { return nil }
        let pcNoDuplicates = Array(Set(pitchCollection))
        let pcNormalForm = normalForm(of: pcNoDuplicates)
        let zeroBasedNormalForm = pcNormalForm.map { ($0.rawValue - pcNormalForm[0].rawValue + 12) % 12 }
        if let tonalChordType = allTonalChordsByZeroBasedNormalForm[zeroBasedNormalForm], tonalChordType.rootIndexInNormalForm < pcNormalForm.count {
            let rootIndex = tonalChordType.rootIndexInNormalForm
            let rootPitchClass = pcNormalForm[rootIndex]
            return (rootPitchClass, tonalChordType)
        }
        return nil
    }
        
    mutating func getChordInversion(of pitchCollection: [(PitchClass, Octave)]) -> String? {
        guard pitchCollection.count >= 2 else { return nil }
        guard let bassNoteKeyValue = pitchCollection.map({ keyValue($0) }).min() else { return nil }
        let bassNote = putInRange(keyValue: bassNoteKeyValue)
        let pitchClasses: [PitchClass] = pitchCollection.map { $0.0 }
        let pcNormalForm = normalForm(of: pitchClasses)

        if let bassNoteIndex = pcNormalForm.firstIndex(of: bassNote) {
            return getInversionFromThirdsAboveRoot(for: bassNoteIndex, pitchCollectionInNormalForm: pcNormalForm.map { $0.rawValue })?.rawValue
        }
        return nil
    }
    
    // Transform intervals array into diatonic steps. Use that to calculate number of thirds up from root.
    private func getInversionFromThirdsAboveRoot(for bassIndex: Int, pitchCollectionInNormalForm pc: [Int]) -> TonalChordInversion? {
        guard let pcFirst = pc.first, pc.count > 2 else { return nil }
        let zeroBasedPC = pc.map { ($0 - pcFirst + 12) % 12 }
        guard let chordType = allTonalChordsByZeroBasedNormalForm[zeroBasedPC] else { return nil }
        let rootIndex = chordType.rootIndexInNormalForm
        let zeroBasedDiatonicStepsDiffs = diatonicIntervals(fromZeroBasedNormalFormPC: zeroBasedPC)
        let numStepsFromRoot = (zeroBasedDiatonicStepsDiffs[bassIndex] - zeroBasedDiatonicStepsDiffs[rootIndex] + 7) % 7
        let numThirds = (numStepsFromRoot / 2) + (numStepsFromRoot % 2 * 4)
        return TonalChordInversion(numThirdsAboveRoot: numThirds)
    }
    
    // e.g. [.a, .b, .d, .dSharp, .fSharp] -> [0, 2, 5, 6, 9] -> [0, 2, 3, 1, 3], should be [0, 1, 2, 3, 5]
    private func diatonicIntervals(fromZeroBasedNormalFormPC pc: [Int]) -> [Int] {
        guard pc.count > 2 else { return [pc.reduce(0, { $1 - $0 })] }
        let zeroBasedPCDiffs = pc.enumerated().map { $0.offset == 0 ? 0 : ($0.element - pc[$0.offset - 1]) }
        var zeroBasedNormalFormDiatonicIntervals: [Int] = [0]
        for idx in 1..<pc.count {
            let semitonesUp = zeroBasedPCDiffs[idx]
            let prevSemitonesUp = zeroBasedPCDiffs[zeroBasedPCDiffs.prev(before: idx)]
            let nextSemitonesUp = zeroBasedPCDiffs[zeroBasedPCDiffs.next(after: idx)]
            if semitonesUp == 3 && (prevSemitonesUp == 1 || nextSemitonesUp == 1) {
                let stepsUp = 1
                let prev = zeroBasedNormalFormDiatonicIntervals.last ?? 0
                zeroBasedNormalFormDiatonicIntervals.append(prev + stepsUp)
            } else {
                let stepsUp = (semitonesUp / 2) + (semitonesUp % 2)
                let prev = zeroBasedNormalFormDiatonicIntervals.last ?? 0
                zeroBasedNormalFormDiatonicIntervals.append(prev + stepsUp)
            }
        }
        return zeroBasedNormalFormDiatonicIntervals
    }
    
}
