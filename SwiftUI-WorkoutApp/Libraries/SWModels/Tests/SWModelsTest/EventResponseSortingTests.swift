import Foundation
@testable import SWModels
import SWUtils
import Testing

struct EventResponseSortingTests {
    @Test("Должен сортировать события по дате в порядке убывания")
    func shouldSortEventsByDateDescending() throws {
        let event1 = EventResponse(id: 1, beginDate: "2025-01-01T00:00:00+00:00")
        let event2 = EventResponse(id: 2, beginDate: "2025-01-02T00:00:00+00:00")
        let event3 = EventResponse(id: 3, beginDate: "2025-01-03T00:00:00+00:00")
        let events = [event1, event2, event3]
        let sorted = events.sortedByDate
        #expect(sorted[0].id == 3)
        #expect(sorted[1].id == 2)
        #expect(sorted[2].id == 1)
    }

    @Test("Должен правильно обрабатывать события с одинаковой датой")
    func shouldHandleEventsWithSameDate() throws {
        let event1 = EventResponse(id: 1, beginDate: "2025-01-01T00:00:00+00:00")
        let event2 = EventResponse(id: 2, beginDate: "2025-01-01T00:00:00+00:00")
        let event3 = EventResponse(id: 3, beginDate: "2025-01-01T00:00:00+00:00")
        let events = [event1, event2, event3]
        let sorted = events.sortedByDate
        #expect(sorted.count == 3)
        let sortedIds = sorted.map(\.id)
        #expect(sortedIds.contains(1))
        #expect(sortedIds.contains(2))
        #expect(sortedIds.contains(3))
    }

    @Test("Должен правильно обрабатывать события без даты")
    func shouldHandleEventsWithoutDate() throws {
        let event1 = EventResponse(id: 1, beginDate: nil)
        let event2 = EventResponse(id: 2, beginDate: "2025-01-01T00:00:00+00:00")
        let event3 = EventResponse(id: 3, beginDate: nil)
        let events = [event1, event2, event3]
        let sorted = events.sortedByDate
        #expect(sorted.count == 3)
        let sortedIds = sorted.map(\.id)
        #expect(sortedIds.contains(1))
        #expect(sortedIds.contains(2))
        #expect(sortedIds.contains(3))
    }

    @Test("Должен возвращать пустой массив для пустого массива")
    func shouldReturnEmptyArrayForEmptyArray() {
        let events: [EventResponse] = []
        let sorted = events.sortedByDate
        #expect(sorted.isEmpty)
    }
}
