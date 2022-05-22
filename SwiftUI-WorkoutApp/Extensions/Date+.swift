import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
    var isThisYear: Bool {
        Calendar.current.compare(Date.now, to: self, toGranularity: .year) == .orderedSame
    }
}
