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
        if let dateString = string, !dateString.isEmpty,
           let fullDate = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = DateFormat.fullDateMediumTime.rawValue
            return formatter.string(from: fullDate)
        } else {
            return ""
        }
    }

    static func isoStringFromFullDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateFormat.isoDateTimeSec.rawValue
        return dateFormatter.string(from: date).appending("Z")
    }

    static func dateFromShortIsoString(_ string: String?) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.isoShortDate.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string.valueOrEmpty) ?? .now
    }
}

extension FormatterService {
    enum DateFormat: String {
        case isoShortDate = "yyyy-MM-dd"
        case isoDateTimeSec = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        case fullDateMediumTime = "dd.MM.yyyy, HH:mm"
    }
}
