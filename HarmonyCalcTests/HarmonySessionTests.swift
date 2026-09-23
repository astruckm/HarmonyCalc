//
//  HarmonySessionTests.swift
//  HarmonyCalcTests
//
//  Created by ASM on 9/23/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import XCTest
@testable import HarmonyCalc

final class HarmonySessionTests: XCTestCase {

    // Counts how many times the session reports a change, to verify observer notifications fire on real mutations and stay silent on no-ops.
    private final class SpyObserver: HarmonySessionObserver {
        private(set) var changeCount = 0
        func harmonySessionDidChange(_ session: HarmonySession) { changeCount += 1 }
    }

    private func makeSession(maxNotesInCollection: Int = 7) -> HarmonySession {
        return HarmonySession(harmonyModel: HarmonyModel(maxNotesInCollection: maxNotesInCollection))
    }

    // MARK: maxNotes cap

    func testMaxNotesCapsAtTwelve() {
        XCTAssertEqual(HarmonyModel(maxNotesInCollection: 5).maxNotes, 5)
        XCTAssertEqual(HarmonyModel(maxNotesInCollection: 7).maxNotes, 7)
        XCTAssertEqual(HarmonyModel(maxNotesInCollection: 12).maxNotes, 12)
        XCTAssertEqual(HarmonyModel(maxNotesInCollection: 88).maxNotes, 12)
    }

    func testSessionMaxNotesReflectsModel() {
        XCTAssertEqual(makeSession(maxNotesInCollection: 88).maxNotes, 12)
    }

    // MARK: add / remove / clear + observer notifications

    func testAddInsertsNoteAndNotifiesObserver() {
        let session = makeSession()
        let spy = SpyObserver()
        session.observer = spy

        XCTAssertTrue(session.add(makeNote(.c, 4)))
        XCTAssertTrue(session.heldNotes.contains(makeNote(.c, 4)))
        XCTAssertEqual(spy.changeCount, 1)
    }

    func testAddRejectsDuplicateWithoutNotifying() {
        let session = makeSession()
        let spy = SpyObserver()
        session.observer = spy

        XCTAssertTrue(session.add(makeNote(.c, 4)))
        XCTAssertFalse(session.add(makeNote(.c, 4)))
        XCTAssertEqual(session.heldNotes.count, 1)
        XCTAssertEqual(spy.changeCount, 1)   // only the first add is a real change
    }

    func testAddRespectsCapacity() {
        let session = makeSession(maxNotesInCollection: 3)
        let spy = SpyObserver()
        session.observer = spy

        XCTAssertTrue(session.add(makeNote(.c, 4)))
        XCTAssertTrue(session.add(makeNote(.e, 4)))
        XCTAssertTrue(session.add(makeNote(.g, 4)))
        XCTAssertFalse(session.add(makeNote(.b, 4)))   // 4th note exceeds the cap of 3

        XCTAssertEqual(session.heldNotes.count, 3)
        XCTAssertEqual(spy.changeCount, 3)
    }

    func testRemoveDeletesNoteAndNotifies() {
        let session = makeSession()
        let spy = SpyObserver()
        session.add(makeNote(.c, 4))
        session.observer = spy

        session.remove(makeNote(.c, 4))
        XCTAssertTrue(session.heldNotes.isEmpty)
        XCTAssertEqual(spy.changeCount, 1)
    }

    func testRemoveAbsentNoteDoesNotNotify() {
        let session = makeSession()
        let spy = SpyObserver()
        session.add(makeNote(.c, 4))
        session.observer = spy

        session.remove(makeNote(.g, 4))   // never added
        XCTAssertEqual(session.heldNotes.count, 1)
        XCTAssertEqual(spy.changeCount, 0)
    }

    func testClearEmptiesAndNotifies() {
        let session = makeSession()
        let spy = SpyObserver()
        session.add(makeNote(.c, 4))
        session.add(makeNote(.e, 4))
        session.observer = spy

        session.clear()
        XCTAssertTrue(session.heldNotes.isEmpty)
        XCTAssertEqual(spy.changeCount, 1)
    }

    func testClearWhenEmptyDoesNotNotify() {
        let session = makeSession()
        let spy = SpyObserver()
        session.observer = spy

        session.clear()
        XCTAssertEqual(spy.changeCount, 0)
    }

    // MARK: derived collections

    func testPitchClassesDeduplicateOctavesAndSort() {
        let session = makeSession()
        session.add(makeNote(.g, 4))
        session.add(makeNote(.c, 5))
        session.add(makeNote(.e, 4))
        session.add(makeNote(.c, 4))

        XCTAssertEqual(session.pitchClasses, [.c, .e, .g])
    }

    func testSortedNotesAreAscending() {
        let session = makeSession()
        session.add(makeNote(.g, 4))
        session.add(makeNote(.c, 4))
        session.add(makeNote(.e, 5))

        XCTAssertEqual(session.sortedNotes, [makeNote(.c, 4), makeNote(.g, 4), makeNote(.e, 5)])
    }

    func testNoteNamesFollowSharpFlatSetting() {
        let session = makeSession()
        session.add(makeNote(.c, 4))
        session.add(makeNote(.dSharp, 4))

        XCTAssertEqual(session.noteNames(usingSharps: true), "C, D♯")
        XCTAssertEqual(session.noteNames(usingSharps: false), "C, E♭")
    }

    // MARK: analysis threading

    func testAnalysisThreadsUsingSharpsIntoModel() {
        let session = makeSession()
        session.add(makeNote(.e, 4))
        session.add(makeNote(.c, 5))
        session.add(makeNote(.gSharp, 5))

        XCTAssertEqual(session.analysis(usingSharps: true).primary?.symbol, "C⁺")
        XCTAssertEqual(session.analysis(usingSharps: false).primary?.symbol, "A♭⁺")
    }
}
