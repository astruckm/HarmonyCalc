//
//  NoteProtocols.swift
//  HarmonyCalc
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
}

protocol NoteCollectionConstraintsDelegate {
    var maxTouchableNotes: Int { get }
}

