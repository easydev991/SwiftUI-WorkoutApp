//
//  FormatterService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import Foundation

struct FormatterService {
    static func readableDate(from string: String?) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let dateString = string, !dateString.isEmpty, let fullDate = isoFormatter.date(from: dateString) {
            return custom.string(from: fullDate)
        } else {
            return ""
        }
    }

    static func isoStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.string(from: date).appending("Z")
    }

    static var custom: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = DateFormat.fullDateMediumTime.rawValue
        return formatter
    }
}
