@testable import Utils
import XCTest

final class UtilsTests: XCTestCase {
    func testStringWithoutHTML() {
        let htmlString = "<p>Строка с тегами html.<p>"
        let cleanString = htmlString.withoutHTML
        XCTAssertEqual(cleanString, "Строка с тегами html.")
    }

    func testTrueCountIsOne() {
        let testString = " 1"
        XCTAssertEqual(testString.trueCount, 1)
    }

    func testTrueCountIsZero() {
        let testString = " "
        XCTAssertEqual(testString.trueCount, 0)
    }

    func testWithoutSpaces() {
        let stringWithSpaces = "Hello World from workout"
        let cleanString = stringWithSpaces.withoutSpaces
        XCTAssertEqual(cleanString, "HelloWorldfromworkout")
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

    func testPrettyJson() {
        struct TestModel: Codable { let property: String }
        let data = try! JSONEncoder().encode(TestModel(property: "property"))
        let prettyJson = data.prettyJson
        let expectedResult = """
        {
          "property" : "property"
        }
        """
        XCTAssertEqual(prettyJson, expectedResult)
    }

    func testReadableDate() {
        let stringDate = "2022-10-30T09:00:00+00:00"
        let formattedResult = DateFormatterService.readableDate(from: stringDate, locale: .init(identifier: "ru_RU"))
        let expectedString = "30 окт. 2022"
        XCTAssertEqual(formattedResult, expectedString)
    }

    func testStringFromFullDate_serverDateTimeSec() {
        let date = Date(timeIntervalSinceReferenceDate: 695987883.572933)
        let formattedResult = DateFormatterService.stringFromFullDate(date, format: .serverDateTimeSec, iso: false)
        let expectedString = "2023-01-21T12:58:03"
        XCTAssertEqual(formattedResult, expectedString)
    }

    func testDateFromIsoString_isoDateTimeSec() {
        let stringDate = "2023-01-21T10:05:35+00:00"
        let formattedResult = DateFormatterService.dateFromIsoString(stringDate)
        let expectedDate = Date(timeIntervalSinceReferenceDate: 695988335.0)
        XCTAssertEqual(formattedResult, expectedDate)
    }

    func testDateFromString_isoShortDate() {
        let stringDate = "1992-08-12"
        let formattedResult = DateFormatterService.dateFromString(stringDate, format: .isoShortDate)
        let expectedDate = Date(timeIntervalSinceReferenceDate: -264744000.0)
        XCTAssertEqual(formattedResult, expectedDate)
    }

    func testDaysBetween() {
        let firstDateString = "2023-01-12T00:00:00"
        let secondDateComponents = DateComponents(year: 2023, month: 10, day: 14)
        let secondDate = Calendar.current.date(from: secondDateComponents)!
        let daysBetween = DateFormatterService.days(from: firstDateString, to: secondDate)
        XCTAssertEqual(daysBetween, 275)
    }
}
