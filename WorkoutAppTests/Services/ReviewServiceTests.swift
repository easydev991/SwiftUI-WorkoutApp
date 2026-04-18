import Foundation
import Testing
@testable import WorkoutApp

@MainActor
struct ReviewServiceTests {
    private let filterApplyCountKey = "reviewFilterApplyCount"
    private let filterAttemptedMilestonesKey = "reviewFilterAttemptedMilestones"

    private func makeDefaults() -> UserDefaults {
        let suiteName = "ReviewServiceTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private func makeService(defaults: UserDefaults) -> ReviewService {
        ReviewService(defaults: defaults)
    }

    private func getFilterCount(from defaults: UserDefaults) -> Int {
        defaults.integer(forKey: filterApplyCountKey)
    }

    private func getAttemptedMilestones(from defaults: UserDefaults) -> [Int] {
        defaults.array(forKey: filterAttemptedMilestonesKey) as? [Int] ?? []
    }

    private func setFilterCount(_ value: Int, in defaults: UserDefaults) {
        defaults.set(value, forKey: filterApplyCountKey)
    }

    private func setAttemptedMilestones(_ value: [Int], in defaults: UserDefaults) {
        defaults.set(value, forKey: filterAttemptedMilestonesKey)
    }

    @Test("первый вызов requestReviewIfAppropriate() выставляет pendingRequest")
    func firstRequestReviewIfAppropriateSetsPendingRequestTrue() {
        let service = makeService(defaults: makeDefaults())

        service.requestReviewIfAppropriate()

        #expect(service.pendingRequest)
    }

    @Test("повторный вызов requestReviewIfAppropriate() в этой же сессии не создаёт новый запрос")
    func secondRequestReviewIfAppropriateInSameSessionDoesNotCreateNewRequest() {
        let service = makeService(defaults: makeDefaults())

        service.requestReviewIfAppropriate()
        service.requestReviewIfAppropriate()

        #expect(service.pendingRequest)
    }

    @Test("markConsumed() сбрасывает pendingRequest")
    func markConsumedResetsPendingRequestToFalse() {
        let service = makeService(defaults: makeDefaults())

        service.requestReviewIfAppropriate()
        service.markConsumed()

        #expect(!service.pendingRequest)
    }

    @Test("после markConsumed() повторный requestReviewIfAppropriate() в этой же сессии всё ещё заблокирован")
    func afterMarkConsumedSecondRequestIsStillBlocked() {
        let service = makeService(defaults: makeDefaults())

        service.requestReviewIfAppropriate()
        service.markConsumed()
        service.requestReviewIfAppropriate()

        #expect(!service.pendingRequest)
    }

    @Test("didApplyFilter() увеличивает счётчик фильтра")
    func didApplyFilterIncrementsCounter() {
        let defaults = makeDefaults()
        let service = makeService(defaults: defaults)

        service.didApplyFilter()

        #expect(getFilterCount(from: defaults) == 1)
    }

    @Test("порог 2 триггерит запрос")
    func threshold2TriggersRequest() {
        let defaults = makeDefaults()
        let service = makeService(defaults: defaults)
        setFilterCount(1, in: defaults)

        service.didApplyFilter()

        #expect(service.pendingRequest)
        #expect(getFilterCount(from: defaults) == 2)
    }

    @Test("значение 3 не триггерит запрос")
    func value3DoesNotTriggerRequest() {
        let defaults = makeDefaults()
        let service = makeService(defaults: defaults)
        setFilterCount(3, in: defaults)
        setAttemptedMilestones([2], in: defaults)

        service.didApplyFilter()

        #expect(!service.pendingRequest)
        #expect(getFilterCount(from: defaults) == 4)
    }

    @Test("порог 5 триггерит запрос")
    func threshold5TriggersRequest() {
        let defaults = makeDefaults()
        let service = makeService(defaults: defaults)
        setFilterCount(4, in: defaults)
        setAttemptedMilestones([2], in: defaults)

        service.didApplyFilter()

        #expect(service.pendingRequest)
        #expect(getFilterCount(from: defaults) == 5)
    }

    @Test("порог 15 триггерит запрос")
    func threshold15TriggersRequest() {
        let defaults = makeDefaults()
        let service = makeService(defaults: defaults)
        setFilterCount(14, in: defaults)
        setAttemptedMilestones([2, 5], in: defaults)

        service.didApplyFilter()

        #expect(service.pendingRequest)
        #expect(getFilterCount(from: defaults) == 15)
    }

    @Test("значение 16 не триггерит запрос")
    func value16DoesNotTriggerRequest() {
        let defaults = makeDefaults()
        let service = makeService(defaults: defaults)
        setFilterCount(16, in: defaults)
        setAttemptedMilestones([2, 5, 15], in: defaults)

        service.didApplyFilter()

        #expect(!service.pendingRequest)
        #expect(getFilterCount(from: defaults) == 17)
    }

    @Test("счётчик фильтра сохраняется между инстансами через UserDefaults suite")
    func filterCounterPersistsBetweenInstances() {
        let defaults = makeDefaults()
        let service1 = makeService(defaults: defaults)
        service1.didApplyFilter()
        service1.didApplyFilter()

        #expect(getFilterCount(from: defaults) == 2)
    }

    @Test("milestone фильтра сохраняется только после markConsumed()")
    func filterMilestoneStoredOnlyAfterMarkConsumed() {
        let defaults = makeDefaults()
        setFilterCount(4, in: defaults)
        setAttemptedMilestones([2], in: defaults)

        let service = makeService(defaults: defaults)
        service.didApplyFilter()

        #expect(service.pendingRequest)
        #expect(getFilterCount(from: defaults) == 5)
        #expect(getAttemptedMilestones(from: defaults) == [2])

        service.markConsumed()

        #expect(getAttemptedMilestones(from: defaults) == [2, 5])
    }

    @Test("пропущенный milestone 5 догоняется в новой сессии на следующем применении фильтра")
    func skippedMilestoneIsRequestedInNextSession() {
        let defaults = makeDefaults()
        setFilterCount(2, in: defaults)
        setAttemptedMilestones([2], in: defaults)

        let session1 = makeService(defaults: defaults)
        session1.requestReviewIfAppropriate()
        session1.markConsumed()

        session1.didApplyFilter()
        session1.didApplyFilter()
        session1.didApplyFilter()
        #expect(getFilterCount(from: defaults) == 5)
        #expect(!session1.pendingRequest)
        #expect(getAttemptedMilestones(from: defaults) == [2])

        let session2 = makeService(defaults: defaults)
        session2.didApplyFilter()

        #expect(getFilterCount(from: defaults) == 6)
        #expect(session2.pendingRequest)
    }
}
