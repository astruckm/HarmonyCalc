//
//  IntervalTypes.swift
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


