import Foundation
import OSLog
import SwiftUI

@MainActor
final class ReviewService: ObservableObject {
    @Published private(set) var pendingRequest = false

    private var didRequestThisSession = false
    private var pendingFilterMilestone: Int?
    private let defaults: UserDefaults
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ReviewService.self)
    )

    private let filterApplyCountKey = "reviewFilterApplyCount"
    private let completedFilterMilestonesKey = "reviewFilterAttemptedMilestones"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func requestReviewIfAppropriate() {
        guard didRequestThisSession == false else {
            logger.info("Запрос оценки пропущен: уже запрошен в текущей сессии")
            return
        }
        didRequestThisSession = true
        pendingRequest = true
        logger.info("Запрос оценки отмечен как ожидающий")
    }

    func markConsumed() {
        if let milestone = pendingFilterMilestone {
            storeAttemptedFilterMilestone(milestone)
            pendingFilterMilestone = nil
        }
        pendingRequest = false
        logger.info("Запрос оценки выполнен (pending очищен)")
    }

    func didApplyFilter() {
        let previousCount = defaults.integer(forKey: filterApplyCountKey)
        let newCount = previousCount + 1
        defaults.set(newCount, forKey: filterApplyCountKey)
        logger.info("Фильтр применён, счётчик: \(newCount)")

        guard !didRequestThisSession else {
            logger.info("Запрос оценки фильтра пропущен: уже запрошен в текущей сессии")
            return
        }

        guard let milestone = nextPendingFilterMilestone(for: newCount) else { return }
        logger.info("Порог фильтра достигнут: \(milestone), триггерится запрос оценки")
        pendingFilterMilestone = milestone
        requestReviewIfAppropriate()
    }

    private func nextPendingFilterMilestone(for count: Int) -> Int? {
        let completedMilestones = completedFilterMilestones
        if count >= 15, !completedMilestones.contains(15) {
            return 15
        }
        if count >= 5, !completedMilestones.contains(5) {
            return 5
        }
        if count >= 2, !completedMilestones.contains(2) {
            return 2
        }
        return nil
    }

    private var completedFilterMilestones: Set<Int> {
        let saved = defaults.array(forKey: completedFilterMilestonesKey) as? [Int] ?? []
        return Set(saved)
    }

    private func storeAttemptedFilterMilestone(_ milestone: Int) {
        var completedMilestones = completedFilterMilestones
        guard !completedMilestones.contains(milestone) else { return }
        completedMilestones.insert(milestone)
        defaults.set(Array(completedMilestones).sorted(), forKey: completedFilterMilestonesKey)
        logger.info("Milestone фильтра отмечен как выполненный: \(milestone)")
    }
}
