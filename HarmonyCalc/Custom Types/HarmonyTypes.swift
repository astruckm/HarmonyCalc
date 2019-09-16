//
//  HarmonyTypes.swift
//  Chord Calculator
//
//  Created by ASM on 8/15/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

//MARK: Intervals
typealias IntervalComponents = (quality: IntervalQuality, size: IntervalDiatonicSize)

public enum PitchIntervalClass: Int, Hashable, Equatable {
    case zero = 0, one, two, three, four, five, six, seven, eight, nine, ten, eleven
    
    var possibleIntervalComponents: [IntervalComponents] {
        switch self {
        case .zero: return [(.perfect, .unison)]
        case .one: return [(.minor, .second), (.augmented, .unison)]
        case .two: return [(.major, .second), (.diminished, .third)]
        case .three: return [(.minor, .third), (.augmented, .second)]
        case .four: return [(.major, .third), (.diminished, .fourth)]
        case .five: return [(.perfect, .fourth), (.augmented, .third)]
        case .six: return [(.diminished, .fifth), (.augmented, .fourth)]
        case .seven: return [(.perfect, .fifth), (.diminished, .sixth)]
        case .eight: return [(.minor, .sixth), (.augmented, .fifth)]
        case .nine: return [(.major, .sixth), (.diminished, .seventh)]
        case .ten: return [(.minor, .seventh), (.augmented, .sixth)]
        case .eleven: return [(.major, .seventh), (.diminished, .unison)]
        }
    }
}

public enum IntervalQuality: String, CaseIterable, Comparable, Equatable {
    case diminished, minor, perfect, major, augmented

    public static func < (lhs: IntervalQuality, rhs: IntervalQuality) -> Bool {
        let lhsIndex = IntervalQuality.allCases.firstIndex(of: lhs)!
        let rhsIndex = IntervalQuality.allCases.firstIndex(of: rhs)!
        return lhsIndex < rhsIndex
    }
    
}

//Note these are all within an octave
public enum IntervalDiatonicSize: String, CaseIterable {
    case unison, second, third, fourth, fifth, sixth, seventh, octave
    
    var numSteps: Int {
        switch self {
        case .unison: return 0; case .second: return 1; case .third: return 2; case .fourth: return 3; case .fifth: return 4; case .sixth: return 5; case .seventh: return 6; case .octave: return 7
        }
    }
    
    var possibleQualities: [IntervalQuality] {
        switch self {
        case .unison: return [.perfect]
        case .second: return [.minor, .major, .augmented]
        case .third: return [.diminished, .minor, .major, .augmented]
        case .fourth: return [.diminished, .perfect, .augmented]
        case .fifth: return [.diminished, .perfect, .augmented]
        case .sixth: return [.diminished, .minor, .major, .augmented]
        case .seventh: return [.diminished, .minor, .major]
        case .octave: return [.perfect]
        }
    }
    
    //Indices match up with those of possibleQualities
    var possiblePitchIntervalClass: [PitchIntervalClass] {
        switch self {
        case .unison: return [.zero]
        case .second: return [.one, .two, .three]
        case .third: return [.two, .three, .four, .five]
        case .fourth: return [.four, .five, .six]
        case .fifth: return [.six, .seven, .eight]
        case .sixth: return [.seven, .eight, .nine, .ten]
        case .seventh: return [.nine, .ten, .eleven]
        case .octave: return [.zero]
        }
    }
}

public struct Interval: CustomStringConvertible, Equatable, Comparable {
    let pitchIntervalClass: PitchIntervalClass
    let quality: IntervalQuality
    let size: IntervalDiatonicSize
    
    public var description: String {
        return quality.rawValue + " " + size.rawValue
    }
    
    init?(quality: IntervalQuality, size: IntervalDiatonicSize) {
        for (index, possibleQuality) in size.possibleQualities.enumerated() {
            if possibleQuality == quality {
                self.pitchIntervalClass = size.possiblePitchIntervalClass[index]
                self.quality = quality
                self.size = size
                return
            }
        }
        print("Interval is not possible: interval quality does not apply to that interval size")
        return nil
    }
    
    init?(intervalClass: PitchIntervalClass, size: IntervalDiatonicSize) {
        for possibleInterval in intervalClass.possibleIntervalComponents {
            if possibleInterval.size == size {
                self.pitchIntervalClass = intervalClass
                self.quality = possibleInterval.quality
                self.size = size
                return
            }
        }
        print("Interval is not possible: pitch interval class and interval size combination not possible")
        return nil
    }
    
    public static func < (lhs: Interval, rhs: Interval) -> Bool {
        return lhs.pitchIntervalClass.rawValue < rhs.pitchIntervalClass.rawValue
    }

}


//MARK: Chords
public enum TonalChordType: String, CaseIterable {
    case major = "Maj", minor = "min", diminished = "o", augmented = "+", suspended = "Sus", dominantSeventh = "⁷", minorSeventh = "min⁷", majorSeventh = "Maj⁷", diminishedSeventh = "o⁷", halfDiminishedSeventh = "ø⁷"
    //TODO: add other seventh chords? augmented, suspended4, suspended2? (and suspended 2 chord)
    
    //TODO: Make these in normal form instead?
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
        allNotes.sort { (note0, note1) -> Bool in
            let note0RelativePC = (note0.pitchClass.rawValue - root.pitchClass.rawValue + PitchClass.allCases.count) % PitchClass.allCases.count
            let note1RelativePC = (note1.pitchClass.rawValue - root.pitchClass.rawValue + PitchClass.allCases.count) % PitchClass.allCases.count
            return note0RelativePC < note1RelativePC
        }
        print("allNotes sorted: ", allNotes)
        
        var third: Note? = nil
        var fifth: Note? = nil
        var chordType: TonalChordType? = nil
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
        intervalsFromRoot.sort(by: {$0 < $1})
        for tonalChordType in TonalChordType.allCases {
            if tonalChordType.orderedIntervalsInRootPosition == intervalsFromRoot {
                chordType = tonalChordType
            }
        }
        
        self.third = third
        self.fifth = fifth
        self.chordType = chordType
        self.extensions = extensions
    }
    
    
    
    //TODO: Init? methods from: collection of just PitchIntervalClasses
}




//TODO: all scale types, derived from chord types
public enum ScaleName: String {
    case major, naturalMinor, harmonicMinor, melodicMinor
}

public struct Scale {
    let notes: [Note]
    let tonic: Note
    let name: ScaleName
    
    //TODO:
    //TODO: init
}
