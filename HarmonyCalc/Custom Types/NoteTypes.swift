//
//  NoteTypes.swift
//  Chord Calculator
//
//  Created by ASM on 3/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation


typealias PianoKey = (pitchClass: PitchClass, octave: Octave) ///i.e. a key on the piano

public enum PitchClass: Int, Comparable, Hashable, CaseIterable {
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

public enum NoteLetter: String, Equatable, CaseIterable, Hashable {
    case c = "C", d = "D", e = "E", f = "F", g = "G", a = "A", b = "B"
    
    //To compare scale degrees in a diatonic scale
    var abstractTonalScaleDegree: Int {
        switch self {
        case .c: return 1
        case .d: return 2
        case .e: return 3
        case .f: return 4
        case .g: return 5
        case .a: return 6
        case .b: return 7
        }
    }
}

public enum Octave: Int, Equatable, CaseIterable, Hashable {
    case zero = 0
    case one = 1
}

public struct Note: Comparable, CustomStringConvertible, Hashable {
    let pitchClass: PitchClass
    let noteLetter: NoteLetter
    let octave: Octave?
    
    public var description: String {
        for spelling in pitchClass.possibleSpellings {
            if spelling.contains(noteLetter.rawValue) {
                return spelling
            }
        }
        print("Incongruity between pitchClass and noteLetter")
        return pitchClass.possibleSpellings[0]
    }
        
    init?(pitchClass: PitchClass, noteLetter: NoteLetter, octave: Octave?) {
        guard pitchClass.possibleLetterNames.contains(noteLetter) else {
            print("Note is not possible: pitch class and note letter do not match")
            return nil
        }
        
        self.pitchClass = pitchClass
        self.noteLetter = noteLetter
        self.octave = octave
    }
    
    //Higher pitched note is greater
    public static func <(lhs: Note, rhs: Note) -> Bool {
        guard let lhsOctave = lhs.octave, let rhsOctave = rhs.octave else {
            //If octave is nil (i.e. unknown), have to assume they are in the same octave
            return lhs.pitchClass.rawValue < rhs.pitchClass.rawValue
        }
        return keyValue(pitch: (lhs.pitchClass, lhsOctave)) < keyValue(pitch: (rhs.pitchClass, rhsOctave))
    }

}
