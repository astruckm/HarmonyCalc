@testable import HarmonyCalc
import XCTest

final class MainVCTests: XCTestCase {
    func makeMainVC() -> MainViewController {
        let mainVC = MainViewController()
        mainVC.defaults = Defaults(defaultsObj: FakeUserDefaults())
        return mainVC
    }

    func testLoadOutlets() throws {
        let sut = makeMainVC()

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.chordButton, "chordButton outlet is disconnected")
        XCTAssertNotNil(sut.inversionButton, "inversionButton outlet is disconnected")
        XCTAssertNotNil(sut.normalFormButton, "normalFormButton outlet is disconnected")
        XCTAssertNotNil(sut.primeFormButton, "primeFormButton outlet is disconnected")

        XCTAssertNotNil(sut.noteName, "noteName outlet is disconnected")
        XCTAssertNotNil(sut.chord, "chord outlet is disconnected")
        XCTAssertNotNil(sut.inversion, "inversion outlet is disconnected")
        XCTAssertNotNil(sut.normalForm, "normalForm outlet is disconnected")
        XCTAssertNotNil(sut.primeForm, "primeForm outlet is disconnected")

        XCTAssertNotNil(sut.flatSharp, "flatSharp outlet is disconnected")
        XCTAssertNotNil(sut.audioOnOff, "audioOnOff outlet is disconnected")
        XCTAssertNotNil(sut.reset, "reset outlet is disconnected")
        XCTAssertNotNil(sut.piano, "piano outlet is disconnected")
    }

    func testPropertiesDefaultsAfterLoadingView() {
        let sut = makeMainVC()

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.audioOn)
        XCTAssertNotNil(sut.audioOff)
        XCTAssertEqual(sut.reset.currentTitle, "Clear")

        XCTAssertFalse(sut.audioIsOn)
        XCTAssertEqual(sut.audioOnOff.imageView?.image, sut.audioOff)

        XCTAssertFalse(sut.collectionUsesSharps)

        XCTAssertTrue(sut.piano.keyAreas.isEmpty)
    }

    func testPropertiesLoadedFromUserDefaultsAfterLoadingView() {
        let sut = makeMainVC()
        let newFakeUserDefaults = FakeUserDefaults()
        let newDefaults = Defaults(defaultsObj: newFakeUserDefaults)
        newFakeUserDefaults.settings = [
            newDefaults.audioIsOn: true,
            newDefaults.collectionUsesSharps: true
        ]
        sut.defaults = newDefaults

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.audioIsOn)
        XCTAssertEqual(sut.audioOnOff.imageView?.image, sut.audioOn)

        XCTAssertTrue(sut.collectionUsesSharps)
    }

    func testResetIBActionButtonTap() {
        let sut = makeMainVC()

        sut.loadViewIfNeeded()

//        sut.inversion.text = "test"
        // TODO: call a function that sets all outlets and their properties to default values

        tap(sut.reset)

        XCTAssertTrue(sut.piano.keyAreas.isEmpty)
        XCTAssertTrue(sut.piano.touchedNotes.isEmpty)
        XCTAssertTrue(sut.audioEngine.players.isEmpty)
        XCTAssertEqual(sut.noteName.text, " ")
        XCTAssertTrue(sut.session.heldNotes.isEmpty)

        XCTAssertEqual(sut.normalForm.text, " ")
        XCTAssertEqual(sut.primeForm.text, " ")
        XCTAssertEqual(sut.chord.text, " ")
        XCTAssertEqual(sut.inversion.text, " ")
    }

    func testAudioOnOffTapped() {
        let sut = makeMainVC()
        sut.defaults.writeAudioSetting(true)

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.audioIsOn)
        XCTAssertEqual(sut.audioOnOff.imageView?.image, sut.audioOn)

        tap(sut.audioOnOff)

        XCTAssertFalse(sut.audioIsOn)
        XCTAssertEqual(sut.audioOnOff.imageView?.image, sut.audioOff)
        XCTAssertFalse(sut.defaults.readAudioSetting())

        tap(sut.audioOnOff)

        XCTAssertTrue(sut.audioIsOn)
        XCTAssertEqual(sut.audioOnOff.imageView?.image, sut.audioOn)
        XCTAssertTrue(sut.defaults.readAudioSetting())
    }

    func testFlatSharpTappedChangesCollectionUsesSharps() {
        let sut = makeMainVC()
        sut.defaults.writeCollectionUsesSharps(true)

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.collectionUsesSharps)
        XCTAssertEqual(sut.flatSharp.titleLabel?.text, "♯ / ♭")

        tap(sut.flatSharp)

        XCTAssertFalse(sut.collectionUsesSharps)
    }

    // TODO: testFlatSharpTapped changes all the chord labels text
}

