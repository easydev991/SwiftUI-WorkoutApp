import Foundation

struct FormatterService {
    static func readableDate(from string: String?) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let dateString = string, !dateString.isEmpty,
           let fullDate = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = Locale.autoupdatingCurrent
            let (prefix, dateFormat) = DateFormat.makeFormat(for: fullDate)
            formatter.dateFormat = dateFormat
            return prefix + formatter.string(from: fullDate)
        } else {
            return ""
        }
    }

    static func stringFromFullDate(
        _ date: Date,
        format: DateFormat = .isoDateTimeSec,
        iso: Bool = true
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format.rawValue
        var string = dateFormatter.string(from: date)
        if iso { string.append("Z") }
        return string
    }

    static func serverFiveMinutesAgo(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateFormat.serverDateTimeSec.rawValue
        return dateFormatter.string(from: date)
    }

    static func dateFromIsoString(_ string: String?, format: DateFormat) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        return isoFormatter.date(from: string.valueOrEmpty) ?? .now
    }

    static func dateFromString(_ string: String?, format: DateFormat) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string.valueOrEmpty) ?? .now
    }
}

extension FormatterService {
    enum DateFormat: String {
        case isoShortDate = "yyyy-MM-dd"
        case serverDateTimeSec = "yyyy-MM-dd'T'HH:mm:ss"
        case isoDateTimeSec = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        case fullDateMediumTime = "dd.MM.yyyy, HH:mm"
        case dayMonthMediumTime = "d MMM, HH:mm"
        case dayMonthYear = "d MMM yyyy"
        case mediumTime = "HH:mm"

        static func makeFormat(for date: Date) -> (prefix: String, date: String) {
            if date.isToday {
                return ("", self.mediumTime.rawValue)
            } else if date.isYesterday {
                return ("Вчера, ", self.mediumTime.rawValue)
            } else if date.isThisYear {
                return ("", self.dayMonthMediumTime.rawValue)
            } else {
                return ("", self.dayMonthYear.rawValue)
            }
        }
    }
}
