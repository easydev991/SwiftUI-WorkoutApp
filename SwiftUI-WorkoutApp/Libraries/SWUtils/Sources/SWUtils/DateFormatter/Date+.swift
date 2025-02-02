import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isThisYear: Bool {
        Calendar.current.compare(Date.now, to: self, toGranularity: .year) == .orderedSame
    }
}
