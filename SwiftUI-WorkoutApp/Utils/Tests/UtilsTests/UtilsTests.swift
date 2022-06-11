import XCTest
@testable import Utils

final class UtilsTests: XCTestCase {
    func testStringValueOrEmpty() throws {
        let string: String? = "Test string"
        let stringNil: String? = nil

        XCTAssertNil(stringNil)
        XCTAssertEqual(stringNil.valueOrEmpty, "")
        XCTAssertNotNil(string)
        XCTAssertEqual(string.valueOrEmpty, "Test string")
    }

    func testIntValueOrZero() throws {
        let one: Int? = 1
        let intNil: Int? = nil

        XCTAssertNil(intNil)
        XCTAssertEqual(intNil.valueOrZero, .zero)
        XCTAssertNotNil(one)
        XCTAssertEqual(one.valueOrZero, 1)
    }

    func testBoolIsTrue() throws {
        let bool: Bool? = true
        let boolNil: Bool? = nil

        XCTAssertNil(boolNil)
        XCTAssertEqual(boolNil.isTrue, false)
        XCTAssertNotNil(bool)
        XCTAssertEqual(bool.isTrue, true)
    }

    func testStringWithoutHTML() throws {
        let htmlString = "<p>Строка с тегами html.<p>"
        let cleanString = htmlString.withoutHTML
        XCTAssertEqual(cleanString, "Строка с тегами html.")
    }

    func testCapitalizingFirstLetter() throws {
        let string = "test string"
        let newString = string.capitalizingFirstLetter
        XCTAssertEqual(newString, "Test string")
    }
}
