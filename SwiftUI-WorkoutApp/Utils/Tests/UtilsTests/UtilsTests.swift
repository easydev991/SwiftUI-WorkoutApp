@testable import Utils
import XCTest

final class UtilsTests: XCTestCase {
    func testStringValueOrEmpty() {
        let string: String? = "Test string"
        let stringNil: String? = nil
        XCTAssertNil(stringNil)
        XCTAssertEqual(stringNil.valueOrEmpty, "")
        XCTAssertNotNil(string)
        XCTAssertEqual(string.valueOrEmpty, "Test string")
    }

    func testIntValueOrZero() {
        let one: Int? = 1
        let intNil: Int? = nil
        XCTAssertNil(intNil)
        XCTAssertEqual(intNil.valueOrZero, .zero)
        XCTAssertNotNil(one)
        XCTAssertEqual(one.valueOrZero, 1)
    }

    func testBoolIsTrue() {
        let bool: Bool? = true
        let boolNil: Bool? = nil
        XCTAssertNil(boolNil)
        XCTAssertEqual(boolNil.isTrue, false)
        XCTAssertNotNil(bool)
        XCTAssertEqual(bool.isTrue, true)
    }

    func testStringWithoutHTML() {
        let htmlString = "<p>Строка с тегами html.<p>"
        let cleanString = htmlString.withoutHTML
        XCTAssertEqual(cleanString, "Строка с тегами html.")
    }

    func testCapitalizingFirstLetter() {
        let string = "test string"
        let newString = string.capitalizingFirstLetter
        XCTAssertEqual(newString, "Test string")
    }
    
    func testQueryAllowedURL() {
        let urlString: String? = "https://workout.su/uploads/userfiles/св3.jpg"
        let resultURL = urlString.queryAllowedURL
        XCTAssertEqual(resultURL, URL(string: "https://workout.su/uploads/userfiles/%D1%81%D0%B23.jpg"))
    }
}
