//
//  HarmonySession.swift
//  HarmonyCalc
//
//  Created by ASM on 8/17/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import Foundation

protocol HarmonySessionObserver: AnyObject {
    func harmonySessionDidChange(_ session: HarmonySession)
}

/// Owns the set of currently held notes, runs harmony analysis on them, and notifies its observer whenever the held set changes.
final class HarmonySession {
    private let harmonyModel: HarmonyModel
    private(set) var heldNotes: Set<Note> = []
    weak var observer: HarmonySessionObserver?

    init(harmonyModel: HarmonyModel) {
        self.harmonyModel = harmonyModel
    }

    var maxNotes: Int { return harmonyModel.maxNotes }
    var sortedNotes: [Note] { return heldNotes.sorted() }
    var pitchClasses: [PitchClass] { return Array(Set(heldNotes.map { $0.pitchClass })).sorted(by: <) }

    /// Full harmonic analysis of the held notes: the ranked tonal chord readings plus the post-tonal set-theory data (normal/prime form, interval vector, Forte name).
    func analysis(usingSharps: Bool) -> HarmonyAnalysis {
        return harmonyModel.analyze(sortedNotes, usingSharps: usingSharps)
    }

    @discardableResult
    func add(_ note: Note) -> Bool {
        guard !heldNotes.contains(note), heldNotes.count < maxNotes else { return false }
        heldNotes.insert(note)
        observer?.harmonySessionDidChange(self)
        return true
    }

    func remove(_ note: Note) {
        guard heldNotes.remove(note) != nil else { return }
        observer?.harmonySessionDidChange(self)
    }

    func clear() {
        guard !heldNotes.isEmpty else { return }
        heldNotes.removeAll()
        observer?.harmonySessionDidChange(self)
    }

    func noteNames(usingSharps: Bool) -> String {
        return pitchClasses.map { $0.spelling(usingSharps: usingSharps) }.joined(separator: ", ")
    }
}
