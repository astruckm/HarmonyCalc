//
//  ChordTypes.swift
//  HarmonyCalc
//
//  Created by ASM on 9/24/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation

//MARK: Chords
public enum TonalChordType: String, CaseIterable {
    case major = "Maj", minor = "min", diminished = "o", augmented = "+", suspended = "Sus", dominantSeventh = "⁷", minorSeventh = "min⁷", majorSeventh = "Maj⁷", diminishedSeventh = "o⁷", halfDiminishedSeventh = "ø⁷"
    //TODO: add other seventh chords? augmented, suspended4, suspended2? (and suspended 2 chord)
    
    init?(fromOrderedIntervalsInRootPosition intervals: [Interval]) {
        let icrIntervals = Interval.IntervalsWithinIntervalClassRange()
        
        switch intervals {
        case [icrIntervals.majorThird, icrIntervals.minorThird, icrIntervals.perfectFourth]:
            self = .major
        case [icrIntervals.minorThird, icrIntervals.majorThird, icrIntervals.perfectFourth]:
            self = .minor
        case [icrIntervals.minorThird, icrIntervals.minorThird, icrIntervals.augmentedFourth]:
            self = .diminished
        case [icrIntervals.majorThird, icrIntervals.majorThird, icrIntervals.diminishedFourth]:
            self = .augmented
        case [icrIntervals.perfectFourth, icrIntervals.majorSecond, icrIntervals.perfectFourth]:
            self = .suspended
        case [icrIntervals.majorThird, icrIntervals.majorThird, icrIntervals.minorThird, icrIntervals.majorSecond]:
            self = .dominantSeventh
        case [icrIntervals.minorThird, icrIntervals.majorThird, icrIntervals.minorThird, icrIntervals.majorSecond]:
            self = .minorSeventh
        case [icrIntervals.majorThird, icrIntervals.minorThird, icrIntervals.majorThird, icrIntervals.minorSecond]:
            self = .majorSeventh
        case [icrIntervals.minorThird, icrIntervals.minorThird, icrIntervals.minorThird, icrIntervals.augmentedSecond]:
            self = .diminishedSeventh
        case [icrIntervals.minorThird, icrIntervals.minorThird, icrIntervals.majorThird, icrIntervals.majorSecond]:
            self = .halfDiminishedSeventh
        default: return nil
        }
    }
    
}

public enum ChordalExtensions: String, CaseIterable {
    case second = "2", four = "4", six = "6", seven = "⁷", nine = "9", eleven = "11", thirteen = "13"
    
    var intervalSizeFromRoot: IntervalDiatonicSize {
        switch self {
        case .second: return IntervalDiatonicSize.second
        case .four: return IntervalDiatonicSize.fourth
        case .six: return IntervalDiatonicSize.sixth
        case .seven: return IntervalDiatonicSize.seventh
        case .nine: return IntervalDiatonicSize.second
        case .eleven: return IntervalDiatonicSize.fourth
        case .thirteen: return IntervalDiatonicSize.sixth
        }
    }
    
}

public struct TonalChord {
    let root: Note
    let third: Note?
    let fifth: Note?
    
    let chordType: TonalChordType?
    let extensions: [ChordalExtensions]
    
    //TODO: init? method with only [Note]
    init?(root: Note, otherNotes: [Note]) {
        guard !otherNotes.isEmpty else { return nil }
        
        self.root = root
        //Eliminate duplicates then sort into root position
        var allNotes = [root] + otherNotes
        allNotes = Array(Set<Note>(otherNotes))
        allNotes.sort { (($0.pitchClass.rawValue - root.pitchClass.rawValue + PitchClass.allCases.count) % PitchClass.allCases.count) < (($1.pitchClass.rawValue - root.pitchClass.rawValue + PitchClass.allCases.count) % PitchClass.allCases.count)
        }
        print("allNotes sorted: ", allNotes)
        
        var third: Note? = nil
        var fifth: Note? = nil
//        var chordType: TonalChordType? = nil
        var extensions: [ChordalExtensions] = []
        var intervalsFromRoot: [Interval] = []
        //TODO:
        //1. Loop through each pair of notes and get [Interval] from root
        for note in otherNotes {
            if let intervalFromRoot = interval(between: root, and: note) {
                //2. While doing that, for each note, assign it to third, fifth, or chordal extensions
                switch intervalFromRoot.size {
                case .third:
                    if third != nil { third = note } //TODO: handle duplicates
                case .fifth:
                    if fifth != nil { fifth = note } //TODO: handle duplicates
                default:
                    for chordalExtension in ChordalExtensions.allCases {
                        if intervalFromRoot.size == chordalExtension.intervalSizeFromRoot {
                            extensions.append(chordalExtension)
                        }
                    }
                }
                intervalsFromRoot.append(intervalFromRoot)
            }
        }
        self.third = third
        self.fifth = fifth
        //3. Try to match the [Interval] to one of TonalChordType.allCases.orderIntervalsInRootPosition
        self.chordType = TonalChordType(fromOrderedIntervalsInRootPosition: intervalsFromRoot)
        self.extensions = extensions
    }
    
    
    
    //TODO: Init? methods from: collection of just PitchIntervalClasses
}




