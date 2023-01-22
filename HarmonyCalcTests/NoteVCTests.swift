@testable import HarmonyCalc
import XCTest

final class NoteVCTests: XCTestCase {
    func makeNoteVC() -> NoteViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        return sb.instantiateViewController(withIdentifier: String(describing: NoteViewController.self)) as! NoteViewController
    }

    func testLoadOutlets() throws {
        let sut = makeNoteVC()

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

    func testResetIBActionButtonTap() {
        let sut = makeNoteVC()

        sut.loadViewIfNeeded()

//        sut.inversion.text = "test"
        // TODO: call a function that sets all outlets and their properties to default values

        tap(sut.reset)

        XCTAssertTrue(sut.piano.keyByPathArea.isEmpty)
        XCTAssertTrue(sut.piano.touchedKeys.isEmpty)
        XCTAssertTrue(sut.audioEngine.players.isEmpty)
        XCTAssertEqual(sut.noteName.text, " ")
        XCTAssertTrue(sut.touchedKeys.isEmpty)

        XCTAssertEqual(sut.normalForm.text, " ")
        XCTAssertEqual(sut.primeForm.text, " ")
        XCTAssertEqual(sut.chord.text, " ")
        XCTAssertEqual(sut.inversion.text, " ")
    }
}

func tap(_ button: UIButton) {
    button.sendActions(for: .touchUpInside)
}
