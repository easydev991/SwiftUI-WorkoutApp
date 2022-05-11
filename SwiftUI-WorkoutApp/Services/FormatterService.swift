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

    static var custom: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = DateFormat.fullDateMediumTime.rawValue
        return formatter
    }
}
