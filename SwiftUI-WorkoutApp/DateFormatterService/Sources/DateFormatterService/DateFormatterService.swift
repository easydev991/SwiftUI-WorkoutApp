import Foundation

public enum DateFormatterService {
    public static func readableDate(
        from string: String?,
        locale: Locale = .autoupdatingCurrent,
        showTimeInThisYear: Bool = true
    ) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let dateString = string, !dateString.isEmpty,
           let fullDate = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = locale
            let (prefix, dateFormat) = DateFormat.makeFormat(
                for: fullDate,
                showTimeInThisYear: showTimeInThisYear
            )
            formatter.dateFormat = dateFormat
            return prefix + formatter.string(from: fullDate)
        } else {
            return ""
        }
    }

    public static func stringFromFullDate(_ date: Date, format: DateFormat = .isoDateTimeSec, iso: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format.rawValue
        var string = dateFormatter.string(from: date)
        if iso { string.append("Z") }
        return string
    }

    public static var fiveMinutesAgoDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateFormat.serverDateTimeSec.rawValue
        let fiveMinutesAgo = Calendar.current.date(byAdding: .minute, value: -5, to: .now) ?? .now
        return dateFormatter.string(from: fiveMinutesAgo)
    }

    public static func dateFromIsoString(_ string: String?) -> Date {
        ISO8601DateFormatter().date(from: string ?? "") ?? .now
    }

    public static func dateFromString(_ string: String?, format: DateFormat) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string ?? "") ?? .now
    }

    /// Считает количество дней между двумя датами
    /// - Parameters:
    ///   - date1: Дата 1
    ///   - date2: Дата 2
    /// - Returns: Количество дней между датами
    public static func days(from serverStringDate1: String, to date2: Date) -> Int {
        let date1 = Self.dateFromString(serverStringDate1, format: .serverDateTimeSec)
        return Self.days(from: date1, to: date2)
    }

    static func days(from date1: Date, to date2: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date1, to: date2).day ?? 0
    }
}

public extension DateFormatterService {
    enum DateFormat: String {
        case isoShortDate = "yyyy-MM-dd"
        case serverDateTimeSec = "yyyy-MM-dd'T'HH:mm:ss"
        case isoDateTimeSec = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        case fullDateMediumTime = "dd.MM.yyyy, HH:mm"
        case dayMonthMediumTime = "d MMM, HH:mm"
        case dayMonthYear = "d MMM yyyy"
        case dayMonth = "d MMM"
        case mediumTime = "HH:mm"

        static func makeFormat(
            for date: Date,
            showTimeInThisYear: Bool
        ) -> (prefix: String, date: String) {
            if date.isToday {
                ("", mediumTime.rawValue)
            } else if date.isYesterday {
                ("Вчера, ", mediumTime.rawValue)
            } else if date.isThisYear {
                (
                    "",
                    showTimeInThisYear ? dayMonthMediumTime.rawValue : dayMonth.rawValue
                )
            } else {
                ("", dayMonthYear.rawValue)
            }
        }
    }
}
