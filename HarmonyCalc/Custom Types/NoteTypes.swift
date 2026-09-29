//
//  NoteTypes.swift
//  HarmonyCalc
//
//  Created by ASM on 3/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation


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
    
    //The letter each possible spelling is written on, in the same order
    var possibleLetterNames: [NoteLetter] {
        return possibleSpellings.compactMap { NoteLetter(rawValue: String($0.prefix(1))) }
    }

    //Default spelling for the collection's sharps/flats preference
    func spelling(usingSharps: Bool) -> String {
        if isBlackKey && !usingSharps { return possibleSpellings[1] }
        return possibleSpellings[0]
    }

    public static func <(lhs: PitchClass, rhs: PitchClass) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public enum NoteLetter: String, Equatable, CaseIterable {
    case c = "C", d = "D", e = "E", f = "F", g = "G", a = "A", b = "B"
}

/// A single sounding note, identified by its MIDI note number.
/// `preferredSpelling` optionally pins an enharmonic name (e.g. E♯ vs F); it never affects pitch, ordering, or set membership.
public struct Note: Comparable, Hashable, CustomStringConvertible {
    let midiNoteNumber: Int
    let preferredSpelling: NoteLetter?

    var pitchClass: PitchClass {
        // The initializer guarantees 0...127, so the remainder is never negative
        return PitchClass(rawValue: midiNoteNumber % 12)!
    }

    // MIDI 60 (middle C) is octave 4
    var octave: Int {
        return (midiNoteNumber / 12) - 1
    }

    public var description: String {
        if let preferredSpelling = preferredSpelling,
           let spelling = pitchClass.possibleSpellings.first(where: { $0.hasPrefix(preferredSpelling.rawValue) }) {
            return spelling
        }
        return pitchClass.possibleSpellings[0]
    }

    init?(midiNoteNumber: Int, preferredSpelling: NoteLetter? = nil) {
        guard (0...127).contains(midiNoteNumber) else {
            print("Note is not possible: MIDI note number out of range")
            return nil
        }
        self.midiNoteNumber = midiNoteNumber
        self.preferredSpelling = preferredSpelling
        if let preferredSpelling = preferredSpelling {
            guard pitchClass.possibleLetterNames.contains(preferredSpelling) else {
                print("Note is not possible: pitch class and preferred spelling do not match")
                return nil
            }
        }
    }

    init?(pitchClass: PitchClass, octave: Int, preferredSpelling: NoteLetter? = nil) {
        self.init(midiNoteNumber: (octave + 1) * 12 + pitchClass.rawValue, preferredSpelling: preferredSpelling)
    }

    //Ordering and identity follow pitch alone; enharmonic spellings are equal.
    public static func < (lhs: Note, rhs: Note) -> Bool {
        return lhs.midiNoteNumber < rhs.midiNoteNumber
    }

    public static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.midiNoteNumber == rhs.midiNoteNumber
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(midiNoteNumber)
    }
}
