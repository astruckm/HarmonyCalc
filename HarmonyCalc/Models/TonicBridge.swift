//
//  TonicBridge.swift
//  HarmonyCalc
//
//  Created by ASM on 6/25/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import Tonic

func pitchClass(from noteClass: NoteClass) -> PitchClass? {
    return PitchClass(rawValue: Int(noteClass.canonicalNote.pitch.pitchClass))
}

func spellingComplexity(of noteClass: NoteClass) -> Int {
    return abs(Int(noteClass.accidental.rawValue))
}

enum TonalChordInversion: String, CaseIterable {
    case root = "Root"
    case first = "1st"
    case second = "2nd"
    case third = "3rd"
    case fourth = "4th"
    case fifth = "5th"
    case sixth = "6th"
    
    init(inversionIndex: Int) {
        let index = inversionIndex % TonalChordInversion.allCases.count
        self = TonalChordInversion.allCases[index]
    }
}
