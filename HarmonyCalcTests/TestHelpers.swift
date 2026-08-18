//
//  TestHelpers.swift
//  HarmonyCalcTests
//
//  Created by Andrew Struck-Marcell on 2/2/23.
//  Copyright © 2023 ASM. All rights reserved.
//

@testable import HarmonyCalc
import UIKit

func tap(_ button: UIButton) {
    button.sendActions(for: .touchUpInside)
}

func makeNote(_ pitchClass: PitchClass, _ octave: Int, spelledAs preferredSpelling: NoteLetter? = nil) -> Note {
    guard let note = Note(pitchClass: pitchClass, octave: octave, preferredSpelling: preferredSpelling) else {
        preconditionFailure("Invalid test note: \(pitchClass) octave \(octave)")
    }
    return note
}

class FakeUserDefaults: UserDefaultsProtocol {
    var settings: [String: Bool] = [:]

    func bool(forKey defaultName: String) -> Bool {
        return settings[defaultName] ?? false
    }

    func set(_ value: Bool, forKey defaultName: String) {
        settings[defaultName] = value
    }

}
