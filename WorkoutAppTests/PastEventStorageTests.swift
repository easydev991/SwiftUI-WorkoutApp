import Foundation
import SWModels
import SWUtils
import Testing
@testable import WorkoutApp

struct PastEventStorageTests {
    @Test("Должен возвращать пустой массив если файл не существует")
    func shouldReturnEmptyArrayIfFileNotExists() {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.dataToReturn = [EventResponse]()
        let storage = PastEventStorage(storage: mockStorage)
        #expect(storage.savedPastEvents.isEmpty)
    }

    @Test("Должен возвращать сохраненные события если файл существует")
    func shouldReturnSavedEventsIfFileExists() throws {
        let mockStorage = MockSWFileManagerImp()
        let testEvent = makeEvent(id: 1)
        mockStorage.dataToReturn = [testEvent]
        let storage = PastEventStorage(storage: mockStorage)
        let savedEvents = storage.savedPastEvents
        #expect(savedEvents.count == 1)
        let savedEvent = try #require(savedEvents.first)
        #expect(savedEvent.id == 1)
    }

    @Test("Должен обрабатывать ошибки при загрузке")
    func shouldHandleErrorsOnLoad() {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.errorToThrow = NSError(domain: "TestError", code: 1)
        let storage = PastEventStorage(storage: mockStorage)
        #expect(storage.savedPastEvents.isEmpty)
    }

    @Test("Должен сохранять события если сохраненный список пуст")
    func shouldSaveEventsIfSavedListIsEmpty() {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.dataToReturn = [EventResponse]()
        let storage = PastEventStorage(storage: mockStorage)
        let testEvent = makeEvent(id: 1)
        storage.saveIfNeeded([testEvent])
        #expect(mockStorage.saveCallCount == 1)
    }

    @Test("Должен использовать sortedByDate при первом сохранении")
    func shouldUseSortedByDateOnFirstSave() throws {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.dataToReturn = [EventResponse]()
        let storage = PastEventStorage(storage: mockStorage)
        let event1 = makeEvent(id: 1, beginDate: "2025-01-02T00:00:00+00:00")
        let event2 = makeEvent(id: 2, beginDate: "2025-01-01T00:00:00+00:00")
        storage.saveIfNeeded([event2, event1])
        #expect(mockStorage.saveCallCount == 1)
        let savedData = try #require(mockStorage.savedData as? [EventResponse])
        #expect(savedData.count == 2)
        #expect(savedData[0].id == 1)
        #expect(savedData[1].id == 2)
    }

    @Test("Должен сохранять объединенный список при наличии новых событий")
    func shouldSaveCombinedListWhenNewEventsExist() throws {
        let mockStorage = MockSWFileManagerImp()
        let event1 = makeEvent(id: 1, beginDate: "2025-01-01T00:00:00+00:00")
        mockStorage.dataToReturn = [event1]
        let storage = PastEventStorage(storage: mockStorage)
        let event2 = makeEvent(id: 2, beginDate: "2025-01-02T00:00:00+00:00")
        storage.saveIfNeeded([event2])
        #expect(mockStorage.saveCallCount == 1)
        let savedData = try #require(mockStorage.savedData as? [EventResponse])
        #expect(savedData.count == 2)
        #expect(savedData[0].id == 2)
        #expect(savedData[1].id == 1)
    }

    @Test("Не должен сохранять если все события уже есть в сохраненном списке")
    func shouldNotSaveIfAllEventsAlreadyExist() {
        let mockStorage = MockSWFileManagerImp()
        let testEvent = makeEvent(id: 1)
        mockStorage.dataToReturn = [testEvent]
        let storage = PastEventStorage(storage: mockStorage)
        storage.saveIfNeeded([testEvent])
        #expect(mockStorage.saveCallCount == 0)
    }

    @Test("Должен добавлять только новые события к существующим и использовать sortedByDate")
    func shouldAddOnlyNewEventsAndUseSortedByDate() throws {
        let mockStorage = MockSWFileManagerImp()
        let event1 = makeEvent(id: 1, beginDate: "2025-01-01T00:00:00+00:00")
        let event2 = makeEvent(id: 2, beginDate: "2025-01-02T00:00:00+00:00")
        mockStorage.dataToReturn = [event1, event2]
        let storage = PastEventStorage(storage: mockStorage)
        let event3 = makeEvent(id: 3, beginDate: "2025-01-03T00:00:00+00:00")
        storage.saveIfNeeded([event2, event3])
        #expect(mockStorage.saveCallCount == 1)
        let savedData = try #require(mockStorage.savedData as? [EventResponse])
        #expect(savedData.count == 3)
        let savedIds = savedData.map(\.id)
        #expect(savedIds.contains(1))
        #expect(savedIds.contains(2))
        #expect(savedIds.contains(3))
        #expect(savedData[0].id == 3)
        #expect(savedData[1].id == 2)
        #expect(savedData[2].id == 1)
    }

    @Test("Должен обрабатывать ошибки сохранения")
    func shouldHandleSaveErrors() {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.errorToThrow = NSError(domain: "TestError", code: 1)
        let storage = PastEventStorage(storage: mockStorage)
        let testEvent = makeEvent(id: 1)
        storage.saveIfNeeded([testEvent])
    }

    @Test("Должен передавать правильные данные в storage.save при первом сохранении")
    func shouldPassCorrectDataOnFirstSave() throws {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.dataToReturn = [EventResponse]()
        let storage = PastEventStorage(storage: mockStorage)
        let testEvent = makeEvent(id: 1)
        storage.saveIfNeeded([testEvent])
        let savedData = try #require(mockStorage.savedData as? [EventResponse])
        #expect(savedData.count == 1)
        #expect(savedData[0].id == 1)
    }

    @Test("Должен передавать объединенный список отсортированный по дате")
    func shouldPassCombinedListSortedByDate() throws {
        let mockStorage = MockSWFileManagerImp()
        let event1 = makeEvent(id: 1, beginDate: "2025-01-01T00:00:00+00:00")
        mockStorage.dataToReturn = [event1]
        let storage = PastEventStorage(storage: mockStorage)
        let event2 = makeEvent(id: 2, beginDate: "2025-01-02T00:00:00+00:00")
        storage.saveIfNeeded([event2])
        let savedData = try #require(mockStorage.savedData as? [EventResponse])
        #expect(savedData.count == 2)
        #expect(savedData[0].id == 2)
        #expect(savedData[1].id == 1)
    }

    @Test("Должен использовать sortedByDate для объединенного списка")
    func shouldUseSortedByDateForCombinedList() throws {
        let mockStorage = MockSWFileManagerImp()
        let event1 = makeEvent(id: 1, beginDate: "2025-01-01T00:00:00+00:00")
        mockStorage.dataToReturn = [event1]
        let storage = PastEventStorage(storage: mockStorage)
        let event2 = makeEvent(id: 2, beginDate: "2025-01-01T00:00:00+00:00")
        storage.saveIfNeeded([event2])
        let savedData = try #require(mockStorage.savedData as? [EventResponse])
        #expect(savedData.count == 2)
        let savedIds = savedData.map(\.id)
        #expect(savedIds.contains(1))
        #expect(savedIds.contains(2))
    }

    @Test("Должен загружать сохраненные события если список пуст")
    func shouldLoadSavedEventsIfListIsEmpty() throws {
        let mockStorage = MockSWFileManagerImp()
        let testEvent = makeEvent(id: 1)
        mockStorage.dataToReturn = [testEvent]
        let storage = PastEventStorage(storage: mockStorage)
        var pastEvents: [EventResponse] = []
        storage.loadIfNeeded(&pastEvents)
        #expect(pastEvents.count == 1)
        let loadedEvent = try #require(pastEvents.first)
        #expect(loadedEvent.id == 1)
    }

    @Test("Не должен изменять список если он не пуст")
    func shouldNotChangeListIfNotEmpty() {
        let mockStorage = MockSWFileManagerImp()
        let testEvent = makeEvent(id: 1)
        mockStorage.dataToReturn = [testEvent]
        let storage = PastEventStorage(storage: mockStorage)
        let existingEvent = makeEvent(id: 2)
        var pastEvents: [EventResponse] = [existingEvent]
        storage.loadIfNeeded(&pastEvents)
        #expect(pastEvents.count == 1)
        #expect(pastEvents[0].id == 2)
    }

    @Test("Не должен вызывать storage.get если список не пуст")
    func shouldNotCallStorageGetIfListNotEmpty() {
        let mockStorage = MockSWFileManagerImp()
        let storage = PastEventStorage(storage: mockStorage)
        let existingEvent = makeEvent(id: 1)
        var pastEvents: [EventResponse] = [existingEvent]
        storage.loadIfNeeded(&pastEvents)
        #expect(mockStorage.getCallCount == 0)
    }

    @Test("Должен вызывать storage.get если список пуст")
    func shouldCallStorageGetIfListEmpty() {
        let mockStorage = MockSWFileManagerImp()
        let testEvent = makeEvent(id: 1)
        mockStorage.dataToReturn = [testEvent]
        let storage = PastEventStorage(storage: mockStorage)
        var pastEvents: [EventResponse] = []
        storage.loadIfNeeded(&pastEvents)
        #expect(mockStorage.getCallCount == 1)
    }
}

private extension PastEventStorageTests {
    func makeEvent(id: Int, beginDate: String? = nil) -> EventResponse {
        EventResponse(
            id: id,
            beginDate: beginDate ?? "2025-01-01T00:00:00+00:00"
        )
    }
}
