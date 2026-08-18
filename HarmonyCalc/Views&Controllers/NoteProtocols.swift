//
//  NoteProtocols.swift
//  HarmonyCalc
//
//  Created by ASM on 8/15/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

/// A source of note-on/note-off events (a piano, fretboard, MIDI keyboard, etc.).
protocol NoteInputSource: AnyObject {
    var inputDelegate: NoteInputDelegate? { get set }
}

/// Receives note events from a `NoteInputSource`.
protocol NoteInputDelegate: AnyObject {
    func noteInput(_ source: NoteInputSource, noteOn note: Note)
    func noteInput(_ source: NoteInputSource, noteOff note: Note)
    func noteInputDidClear(_ source: NoteInputSource)
}
