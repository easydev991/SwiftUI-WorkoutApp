import Foundation
@testable import SWUtils
import Testing

struct DateRawRepresentableTests {
    @Test(arguments: [
        Date.now,
        .distantPast,
        .distantFuture,
        Date(timeIntervalSinceReferenceDate: 0),
        Date(timeIntervalSinceReferenceDate: 12345.6789)
    ])
    func roundTripConversion(date: Date) {
        let rawValue = date.rawValue
        let reconstructedDate = Date(rawValue: rawValue)
        #expect(reconstructedDate == date)
    }

    @Test(arguments: ["0.0": 0.0, "-1234.56": -1234.56, "123456.789": 123456.789, "1e3": 1000.0, "12345.": 12345.0])
    func validRawValueInitialization(value: (rawValue: String, expectedInterval: Double)) throws {
        let date = try #require(Date(rawValue: value.rawValue))
        #expect(date.timeIntervalSinceReferenceDate == value.expectedInterval)
    }

    @Test(arguments: ["invalid", "12.34.56", "123,45", "", "nil", "123abc"])
    func invalidRawValueInitialization(value: String) {
        let date = Date(rawValue: value)
        #expect(date == nil)
    }

    @Test
    func rawValueFormat() {
        let date = Date(timeIntervalSinceReferenceDate: 12345.6789)
        let rawValue = date.rawValue
        let parsedValue = Double(rawValue)
        #expect(parsedValue == 12345.6789)
    }
}
