//
//  NoteModel.swift
//  Chord Calculator
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//
//  This file is the brain of the calculator, taking in notes and outputting tonal and atonal collections
//

import Foundation

struct HarmonyModel {
    //***************************************************
    //MARK: Properties
    //***************************************************
    
    //TODO: This should be read by NoteViewController, communicated to PianoView
    let maximumNotesInCollection = 6
    
    //TODO: Add more chords?
    //In normal form
    private let tonalChordIntervalsInNormalForm: [String: String] = [
        "[4, 3]": "Maj",
        "[3, 4]": "min",
        "[3, 3]": "o",
        "[4, 4]": "+",
        "[2, 5]": "Sus",
        "[3, 3, 2]": "⁷",
        "[3, 2, 3]": "min⁷",
        "[1, 4, 3]": "Maj⁷",
        "[3, 3, 3]": "o⁷",
        "[2, 3, 3]": "ø⁷"
    ]
    //The index here = ([PitchClass].count of the chord) - intLiteralOfInversionName
    //I.e. how many index "steps" to go through to get to the root
    //(index of bassNote in normal form) - (value here) gives inversion; if < 0, add [PitchClass].count
    private let tonalChordRootIndexInNormalForm: [String: Int?] = [
        "Maj": 0,
        "min": 0,
        "o": 0,
        "+": 0, //placeholder value; will need enharmonic info to determine
        "Sus": 2, //placeholder
        "⁷": 3,
        "min⁷": 2,
        "Maj⁷": 1,
        "o⁷": 0, //placeholder value; will need enharmonic info to determine
        "ø⁷": 1
    ]
    
    //***************************************************
    //MARK: Types
    //***************************************************
    
    //This probably only useful if account for semitone equivalent intervals
    enum PitchIntervalClass: Int, Hashable {
        case unison = 0, minorSecond, majorSecond, minorThird, majorThird, perfectFourth, tritone, perfectFifth, minorSixth, majorSixth, minorSeventh, majorSeventh
    }
    
    enum TonalChordType: String {
        case major = "Maj", minor = "min", diminished = "o", augmented = "+", suspended = "Sus", dominantSeventh = "⁷", minorSeventh = "min⁷", majorSeventh = "Maj⁷", diminishedSeventh = "o⁷", halfDiminishedSeventh = "ø⁷"
    }
    
    //***************************************************
    //MARK: General note transformation funcs
    //***************************************************
    
    //input notes in a chord, output all possible inversions
    private func allInversions(of notes: [PitchClass]) -> [[(PitchClass)]] {
        var allInversionsOfCollection = [[PitchClass]]()
        var inversion = notes.sorted(by: <)
        for _ in 0...(notes.count-1) {
            allInversionsOfCollection.append(inversion)
            let firstNote = inversion.remove(at: 0)
            inversion.append(firstNote)
        }
        return allInversionsOfCollection
    }
    
    //Int value for a key
    func keyValue(pitch: (PitchClass, Octave)) -> Int {
        return pitch.0.rawValue + (pitch.1.rawValue * 12)
    }
    
    //Make any Int a PitchClass
    private func putInRange(keyValue: Int) -> PitchClass {
        if keyValue < 12 && keyValue >= 0 {
            return PitchClass(rawValue: keyValue)!
        }
        
        var newPitchValue = keyValue
        while newPitchValue >= 12 || newPitchValue < 0 {
            if newPitchValue >= 12 { newPitchValue -= 12 }
            if newPitchValue < 0 { newPitchValue += 12 }
        }
        return PitchClass(rawValue: newPitchValue)!
    }
    
    private mutating func intervalNumberBetweenKeys(keyOne: (PitchClass, Octave), keyTwo: (PitchClass, Octave)) -> Int {
        var rawInterval = abs(keyValue(pitch: keyOne) - keyValue(pitch: keyTwo))
        //Put keys in same octave
        rawInterval %= 12
        return rawInterval
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
        guard pitchCollection.count >= 2 else { return [] }
        //TODO: Double check this is correct!
        let pcNoDuplicates = Array(Set(pitchCollection))
        let pitchCollectionInversions = allInversions(of: pcNoDuplicates)
        
        var shortestCollections = [[PitchClass]]()
        
        //Storage variable initialized with value guaranteed to be larger than first intervalSpan
        var shortestDistance = 12
        //Find inversions with shortest first to last distance
        //Put top key (keyOne) an octave above bottom key (keyTwo) to properly account for span
        for collection in pitchCollectionInversions {
            let intervalSpan = intervalNumberBetweenKeys(keyOne: (collection[collection.count-1], Octave.one), keyTwo: (collection[0], Octave.zero))
            if intervalSpan < shortestDistance {
                shortestCollections = [[PitchClass]]()
                shortestCollections.append(collection)
                shortestDistance = intervalSpan
            } else if intervalSpan == shortestDistance {
                shortestCollections.append(collection)
            }
        }
        
        if shortestCollections.count == 1 {
            return shortestCollections[0]
        }
        
        //Loop at least once through length of pitch collections checking span between second-to-last, then third-to-last, etc.
        var shortestCollection = [[PitchClass]]() //singular
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
        
        //Since pitchCollectionInversions should already be sorted to have lowest pitch class inversion first by allInversions(notes:), return first if still a tie (e.g. augmented or fully diminished)
        return pitchCollectionInversions[0]
    }
    
    //Outputs Ints because this is the most reduced kind of set
    mutating func primeForm(of pitchCollection: [PitchClass]) -> [Int] {
        guard pitchCollection.count >= 2 else { return [] }
        let pcNormalForm = normalForm(of: pitchCollection)
        
        let transposedToZero = pcNormalForm.map({
            element -> PitchClass in
            let transposedInt = element.rawValue - pcNormalForm[0].rawValue
            if let transposedElement = PitchClass(rawValue: transposedInt) {
                return transposedElement
            } else if let transposedElementPlusOctave = PitchClass(rawValue: transposedInt+12) {
                return transposedElementPlusOctave
            } else {
                return PitchClass(rawValue: element.rawValue)!
            }
        })
        
        let inversion = pitchCollectionInversion(of: pcNormalForm)
        
        //Use Forte method, packed to left
        var counter = 1
        while counter < pcNormalForm.count {
            if transposedToZero[counter] < inversion[counter] {
                return transposedToZero.map({$0.rawValue})
            } else if transposedToZero[counter] > inversion[counter] {
                return inversion.map({$0.rawValue})
            }
            counter += 1
        }
        
        //if inversion and uninverted are equally packed left
        return transposedToZero.map({$0.rawValue})
    }
    
    //Helper func for Prime form func, so transposes to zero
    private func pitchCollectionInversion(of set: [PitchClass]) -> [PitchClass] {
        let rawInvertedValues = set.map({ 12 - $0.rawValue })
        let invertedValues = rawInvertedValues.map({putInRange(keyValue: $0)})
        let lastPCRawValue = invertedValues[(invertedValues.count-1)].rawValue
        var invertedValuesTransposedToZero = invertedValues.map({element -> PitchClass in
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
        })
        invertedValuesTransposedToZero.sort(by: <)
        return invertedValuesTransposedToZero
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
        //eliminate duplicate notes
        var rawValues = pitchCollection.map({$0.rawValue})
        rawValues = Array(Set(rawValues))
        let pcNoDuplicates: [PitchClass] = rawValues.map { rawValue -> PitchClass in
            guard rawValue >= 0 && rawValue < 12 else { fatalError("Pitch class value error") }
            return PitchClass(rawValue: rawValue)!
        }
        let pcNormalForm = normalForm(of: pcNoDuplicates)
        let intervals = intervalsBetweenPitches(pitchCollection: pcNormalForm)
        //TODO: This chordType String is actually what I want to send to ViewController
        if let chordType = tonalChordIntervalsInNormalForm[intervals.description] {
            if let rootIndex = tonalChordRootIndexInNormalForm[chordType] {
                if let tonalChordType = TonalChordType(rawValue: chordType) {
                    if rootIndex != nil {
                        let rootPitchClass = pcNormalForm[rootIndex!]
                        return (rootPitchClass, tonalChordType)
                    }
                }
            }
        }
        return nil
    }
    
    mutating func getChordInversion(of pitchCollection: [(PitchClass, Octave)]) -> String? {
        guard pitchCollection.count >= 2 else { return nil }
        let pitchClasses: [PitchClass] = pitchCollection.map({$0.0})
        if let chordIdentity = getChordIdentity(of: pitchClasses) {
            if let bassNoteKeyValue = pitchCollection.map({ pc in keyValue(pitch: pc) }).min()
            {
                let bassNote = putInRange(keyValue: bassNoteKeyValue)
                let pcNormalForm = normalForm(of: pitchClasses)
                //See where bassNote's index is in normal form
                if let bassNoteIndex = pcNormalForm.index(of: bassNote) {
                    if let rootIndex = tonalChordRootIndexInNormalForm[chordIdentity.1.rawValue] {
                        var distanceFromRoot = Int(bassNoteIndex) - rootIndex!
                        if distanceFromRoot < 0 { distanceFromRoot += pcNormalForm.count }
                        switch distanceFromRoot {
                        case 0: return "Root position"
                        case 1: return "1st inversion"
                        case 2: return "2nd inversion"
                        case 3: return "3rd inversion"
                        default: return nil
                        }
                    }
                }
            }
        }
        return nil
    }
    
    //TODO: Chord (i.e. root + type/quality), inversion (i.e. root's index), normal form, prime form should all be called by func with massive output that is tuple of every chord form you would want, as Strings. ViewController shouldn't have to type convert.
    func getHarmonyValueForDisplay(of pitchCollection: [(PitchClass, Octave)]) -> (normalForm: String, primeForm: String, chordIdentity: String?, chordInversion: String?) {

        if pitchCollection.count > 1 {
            //Get normal form
            //Use it to get prime form and chord type
            //Use chord type to get inversion
            //Convert everything to Strings
        }
        
        return ("", "", nil, nil)
    }
}
