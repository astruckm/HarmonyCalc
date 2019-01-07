//
//  NoteTypes.swift
//  Chord Calculator
//
//  Created by ASM on 3/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation


typealias Key = (PitchClass, Octave)

public enum PitchClass: Int, Comparable, Hashable {
    case c = 0, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b
    
    var isBlackKey: Bool {
        return String(describing: self).contains("Sharp")
    }
    
    //No double sharps or flats
    var possibleSpellings: [String] {
        switch self {
        case .c: return ["C", "B♯"]
        case .cSharp: return ["C♯", "D♭"]
        case .d: return ["D"]
        case .dSharp: return ["D♯", "E♭"]
        case .e: return ["E", "F♭"]
        case .f: return ["F", "E♯"]
        case .fSharp: return ["F♯", "G♭"]
        case .g: return ["G"]
        case .gSharp: return ["G♯", "A♭"]
        case .a: return ["A"]
        case .aSharp: return ["A♯", "B♭"]
        case .b: return ["B", "C♭"]
        }
    }
    
    var possibleLetterNames: [NoteLetter] {
        switch self {
        case .c: return [.c, .b]
        case .cSharp: return [.c, .d]
        case .d: return [.d]
        case .dSharp: return [.d, .e]
        case .e: return [.e, .f]
        case .f: return [.f, .e]
        case .fSharp: return [.f, .g]
        case .g: return [.g]
        case .gSharp: return [.g, .a]
        case .a: return [.a]
        case .aSharp: return [.a, .b]
        case .b: return [.b, .c]
        }
    }
    
    public static func <(lhs: PitchClass, rhs: PitchClass) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public enum NoteLetter: String {
    case c = "C", d = "D", e = "E", f = "F", g = "G", a = "A", b = "B"
    
    //To compare scale degrees in a diatonic scale
    var abstractTonalScaleDegree: Int {
        switch self {
        case .c: return 0
        case .d: return 1
        case .e: return 2
        case .f: return 3
        case .g: return 4
        case .a: return 5
        case .b: return 6
        }
    }
}

public enum Octave: Int, Equatable {
    case zero = 0
    case one = 1
}

public struct Note {
    let pitchClass: PitchClass
    let noteLetter: NoteLetter
    let octave: Octave?
}
