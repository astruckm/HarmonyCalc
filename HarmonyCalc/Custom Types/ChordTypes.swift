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
        guard let minorSecond = Interval(quality: .minor, size: .second) else { return nil }
        guard let majorSecond = Interval(quality: .major, size: .second) else { return nil }
        guard let augmentedSecond = Interval(quality: .augmented, size: .second) else { return nil }
        guard let minorThird = Interval(quality: .minor, size: .third) else { return nil }
        guard let majorThird = Interval(quality: .major, size: .third) else { return nil }
        guard let diminishedFourth = Interval(quality: .augmented, size: .fourth) else { return nil }
        guard let perfectFourth = Interval(quality: .perfect, size: .fourth) else { return nil }
        guard let augmentedFourth = Interval(quality: .augmented, size: .fourth) else { return nil }
        
        switch intervals {
        case [majorThird, minorThird, perfectFourth]: self = .major
        case [minorThird, majorThird, perfectFourth]: self = .minor
        case [minorThird, minorThird, augmentedFourth]: self = .diminished
        case [majorThird, majorThird, diminishedFourth]: self = .augmented
        case [perfectFourth, majorSecond, perfectFourth]: self = .suspended
        case [majorThird, majorThird, minorThird, majorSecond]: self = .dominantSeventh
        case [minorThird, majorThird, minorThird, majorSecond]: self = .minorSeventh
        case [majorThird, minorThird, majorThird, minorSecond]: self = .majorSeventh
        case [minorThird, minorThird, minorThird, augmentedSecond]: self = .diminishedSeventh
        case [minorThird, minorThird, majorThird, majorSecond]: self = .halfDiminishedSeventh
        default: return nil
        }
    }
    
    //TODO: delete this--redundant now?
    var orderedIntervalsInRootPosition: [Interval] {
        guard let minorSecond = Interval(quality: .minor, size: .second) else { return [] }
        guard let majorSecond = Interval(quality: .major, size: .second) else { return [] }
        guard let augmentedSecond = Interval(quality: .augmented, size: .second) else { return [] }
        guard let minorThird = Interval(quality: .minor, size: .third) else { return [] }
        guard let majorThird = Interval(quality: .major, size: .third) else { return [] }
        guard let diminishedFourth = Interval(quality: .augmented, size: .fourth) else { return [] }
        guard let perfectFourth = Interval(quality: .perfect, size: .fourth) else { return [] }
        guard let augmentedFourth = Interval(quality: .augmented, size: .fourth) else { return [] }
        
        //Includes all possible intervals
        switch self {
        case .major: return [majorThird, minorThird, perfectFourth]
        case .minor: return [minorThird, majorThird, perfectFourth]
        case .diminished: return [minorThird, minorThird, augmentedFourth]
        case .augmented: return [majorThird, majorThird, diminishedFourth]
        case .suspended: return [perfectFourth, majorSecond, perfectFourth]
        case .dominantSeventh: return [majorThird, majorThird, minorThird, majorSecond]
        case .minorSeventh: return [minorThird, majorThird, minorThird, majorSecond]
        case .majorSeventh: return [majorThird, minorThird, majorThird, minorSecond]
        case .diminishedSeventh: return [minorThird, minorThird, minorThird, augmentedSecond]
        case .halfDiminishedSeventh: return [minorThird, minorThird, majorThird, majorSecond]
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
        //3. Try to match the [Interval] to one of TonalChordType.allCases.orderIntervalsInRootPosition
        //        intervalsFromRoot.sort(by: {$0 < $1})
//        for tonalChordType in TonalChordType.allCases {
//            if tonalChordType.orderedIntervalsInRootPosition == intervalsFromRoot {
//                chordType = tonalChordType
//            }
//        }
        
        self.third = third
        self.fifth = fifth
        self.chordType = TonalChordType(fromOrderedIntervalsInRootPosition: intervalsFromRoot)
        self.extensions = extensions
    }
    
    
    
    //TODO: Init? methods from: collection of just PitchIntervalClasses
}




