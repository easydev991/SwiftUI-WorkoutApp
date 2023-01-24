@testable import DateFormatterService
import XCTest

final class DateFormatterServiceTests: XCTestCase {
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
        let formattedResult = DateFormatterService.dateFromIsoString(stringDate, format: .isoDateTimeSec)
        let expectedDate = Date(timeIntervalSinceReferenceDate: 695988335.0)
        XCTAssertEqual(formattedResult, expectedDate)
    }

    func testDateFromString_isoShortDate() {
        let stringDate = "1992-08-12"
        let formattedResult = DateFormatterService.dateFromString(stringDate, format: .isoShortDate)
        let expectedDate = Date(timeIntervalSinceReferenceDate: -264744000.0)
        XCTAssertEqual(formattedResult, expectedDate)
    }
}
