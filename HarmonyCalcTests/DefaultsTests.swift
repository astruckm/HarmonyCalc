@testable import HarmonyCalc
import XCTest

final class DefaultsTests: XCTestCase {
    var defaults: Defaults!

    override func setUp() {
        super.setUp()
        defaults = Defaults(defaultsObj: FakeUserDefaults())
    }

    func testDefaultValueOfDefaultsIsFalse() {
        XCTAssertFalse(defaults.readAudioSetting())
        XCTAssertFalse(defaults.readCollectionUsesSharps())
    }

    func testWritingNewValues() {
        defaults.writeAudioSetting(true)
        defaults.writeCollectionUsesSharps(false)

        XCTAssertTrue(defaults.readAudioSetting())
        XCTAssertFalse(defaults.readCollectionUsesSharps())

        defaults.writeAudioSetting(true)
        defaults.writeCollectionUsesSharps(true)

        XCTAssertTrue(defaults.readAudioSetting())
        XCTAssertTrue(defaults.readCollectionUsesSharps())
    }
}
