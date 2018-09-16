//
//  NoteProtocols.swift
//  Chord Calculator
//
//  Created by ASM on 8/15/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

protocol DisplaysNotes {
    var noteNames: String { get set }
    var touchedKeys: [(PitchClass, Octave)] { get set }
    func noteDisplayNeedsUpdate()
}

protocol PlaysNotes {
    func noteOn(keyPressed: (PitchClass, Octave))
    func noteOff(keyOff: (PitchClass, Octave))
    func allNotesOff(keysOff: [(PitchClass, Octave)])
}

protocol NoteCollectionConstraints {
    var maxTouchableNotes: Int { get }
}
