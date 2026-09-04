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
