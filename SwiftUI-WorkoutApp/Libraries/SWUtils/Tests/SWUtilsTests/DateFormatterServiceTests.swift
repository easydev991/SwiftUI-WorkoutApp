import Foundation
@testable import SWUtils
import Testing

struct DateFormatterServiceTests {
    @Test
    func readableDate() {
        let stringDate = "2022-10-30T09:00:00+00:00"
        let formattedResult = DateFormatterService.readableDate(from: stringDate, locale: .init(identifier: "ru_RU"))
        let expectedString = "30 окт. 2022"
        #expect(formattedResult == expectedString)
    }

    @Test
    func stringFromFullDate_serverDateTimeSec() {
        let date = Date(timeIntervalSinceReferenceDate: 695987883.572933)
        let formattedResult = DateFormatterService.stringFromFullDate(
            date,
            format: .serverDateTimeSec,
            timeZone: TimeZone(secondsFromGMT: 0),
            iso: false
        )
        let expectedString = "2023-01-21T09:58:03"
        #expect(formattedResult == expectedString)
    }

    @Test
    func dateFromIsoString_isoDateTimeSec() {
        let stringDate = "2023-01-21T10:05:35+00:00"
        let formattedResult = DateFormatterService.dateFromIsoString(stringDate)
        let expectedDate = Date(timeIntervalSinceReferenceDate: 695988335.0)
        #expect(formattedResult == expectedDate)
    }

    @Test
    func dateFromString_isoShortDate() throws {
        var utcCalendar = Calendar(identifier: .iso8601)
        utcCalendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let components = DateComponents(
            year: 1992,
            month: 8,
            day: 12,
            hour: 0,
            minute: 0,
            second: 0
        )
        let expectedDate = try #require(utcCalendar.date(from: components))
        let formattedResult = DateFormatterService.dateFromString(
            "1992-08-12",
            format: .isoShortDate,
            timeZone: TimeZone(secondsFromGMT: 0)
        )
        #expect(utcCalendar.isDate(formattedResult, equalTo: expectedDate, toGranularity: .second))
    }

    @Test
    func daysBetween_fromString_toDate() throws {
        let firstDateString = "2023-01-12T00:00:00"
        let secondDateComponents = DateComponents(year: 2023, month: 10, day: 14)
        let secondDate = try #require(Calendar.current.date(from: secondDateComponents))
        let daysBetween = DateFormatterService.days(from: firstDateString, to: secondDate)
        #expect(daysBetween == 275)
    }

    @Test
    func daysBetween_sameDay_returnsZero() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date = try #require(calendar.date(from: .init(year: 2024, month: 6, day: 10)))
        let result = DateFormatterService.days(from: date, to: date)
        #expect(result == 0)
    }

    @Test
    func daysBetween_nextDay_returnsOneDayDifference() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 1)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 2)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == 1)
    }

    @Test
    func daysBetween_previousDay_returnsNegativeOneDayDifference() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 2)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 1)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == -1)
    }

    @Test
    func daysBetween_crossMonth() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 31)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 2, day: 1)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == 1)
    }

    @Test
    func daysBetween_datesWithTime_ignoresTimeComponent() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 1, hour: 23, minute: 59)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 2, hour: 0, minute: 0)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == 1)
    }

    @Test
    func daysBetween_multipleDays() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 1)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 6)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == 5)
    }

    @Test
    func daysBetween_reverseOrder_returnsNegativeDifference() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 10)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 1, day: 5)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == -5)
    }

    @Test
    func daysBetween_leapYearTransition() throws {
        let calendar = Calendar(identifier: .iso8601)
        let date1 = try #require(calendar.date(from: .init(year: 2024, month: 2, day: 28)))
        let date2 = try #require(calendar.date(from: .init(year: 2024, month: 3, day: 1)))
        let result = DateFormatterService.days(from: date1, to: date2)
        #expect(result == 2)
    }
}
