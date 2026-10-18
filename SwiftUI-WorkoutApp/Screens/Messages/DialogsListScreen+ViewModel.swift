import Foundation
import OSLog
import SWModels
import SWNetworkClient

extension DialogsListScreen {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var currentState = CurrentState.initial
        /// Идёт загрузка — повторные вызовы (вкладка + возврат в .active) дедуплицируются (план шаг 5б)
        private var isInFlight = false
        /// Refresh, пришедший во время загрузки: повторится после её окончания вместо тихого пропуска
        private var reloadQueued = false
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "SwiftUI-WorkoutApp",
            category: "DialogsListScreen.ViewModel"
        )
        private let isUITest: Bool
        private let authHelper: AuthHelper
        private let analytics: AnalyticsService
        /// Фабрика клиента диалогов для инъекции мока в тестах; `nil` — клиент создаётся как обычно
        private let makeDialogsClient: ((AuthHelper) -> MessagesClient)?

        init(
            isUITest: Bool = false,
            authHelper: AuthHelper,
            analytics: AnalyticsService = AnalyticsService(),
            makeDialogsClient: ((AuthHelper) -> MessagesClient)? = nil
        ) {
            self.isUITest = isUITest
            self.authHelper = authHelper
            self.analytics = analytics
            self.makeDialogsClient = makeDialogsClient
        }

        func getDialogs(
            refresh: Bool = false,
            defaults: DefaultsService
        ) async {
            guard defaults.isAuthorized else {
                currentState = .initial
                return
            }
            guard !isInFlight else {
                // Refresh во время загрузки не теряем — повторим сразу после неё
                if refresh {
                    reloadQueued = true
                }
                logger.info("Загрузка диалогов уже идёт, повтор вызова отложен")
                return
            }
            guard currentState.shouldLoad || refresh else {
                return
            }
            if !refresh {
                currentState = .loading
            }
            isInFlight = true
            let client: MessagesClient
            #if DEBUG
            if isUITest {
                client = MockSWClient(instantResponse: true)
            } else {
                client = makeDialogsClient?(authHelper) ?? SWClient(with: authHelper)
            }
            #else
            client = makeDialogsClient?(authHelper) ?? SWClient(with: authHelper)
            #endif
            do {
                let dialogs = try await client.getDialogs()
                currentState = .ready(dialogs)
                updateUnreadMessagesCount(with: defaults)
            } catch ClientError.noConnection {
                analytics.log(.appError(kind: .dialogsLoadFailed, error: ClientError.noConnection))
                // Уже загруженный список не затираем ошибкой — обновление просто не удалось
                if currentState.dialogs == nil {
                    currentState = .error(.notConnected)
                } else {
                    logger.info("Нет сети, сохраняем ранее загруженные диалоги")
                }
            } catch {
                analytics.log(.appError(kind: .dialogsLoadFailed, error: error))
                // Любая ошибка обновления (таймаут, 5xx) не затирает уже загруженный список
                if currentState.dialogs == nil {
                    currentState = .error(.common(message: error.localizedDescription))
                } else {
                    logger.info("Ошибка обновления, сохраняем ранее загруженные диалоги")
                }
            }
            isInFlight = false
            await restartQueuedReload(defaults: defaults)
        }

        /// Повторяет refresh, пришедший во время идущей загрузки
        private func restartQueuedReload(defaults: DefaultsService) async {
            guard reloadQueued else { return }
            reloadQueued = false
            await getDialogs(refresh: true, defaults: defaults)
        }

        func deleteDialog(at index: Int?, defaults: DefaultsService) async throws {
            guard let index, let dialogs = currentState.dialogs, currentState.isReadyAndNotEmpty else { return }
            let dialogId = dialogs[index].id
            let updatedDialogs = dialogs.filter { $0.id != dialogId }
            currentState = .deleteDialog(updatedDialogs)
            #if DEBUG
            let client: MessagesClient = isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: authHelper)
            #else
            let client: MessagesClient = SWClient(with: authHelper)
            #endif
            do {
                try await client.deleteDialog(dialogId)
            } catch {
                analytics.log(.appError(kind: .dialogDeleteFailed, error: error))
                throw error
            }
            currentState = .ready(updatedDialogs)
            updateUnreadMessagesCount(with: defaults)
        }

        func markAsRead(_ dialog: DialogResponse, defaults: DefaultsService) {
            guard let dialogs = currentState.dialogs, currentState.isReadyAndNotEmpty else { return }
            let updatedDialogs = dialogs.map { item in
                if item.id == dialog.id {
                    var updatedDialog = dialog
                    updatedDialog.unreadMessagesCount = 0
                    return updatedDialog
                } else {
                    return item
                }
            }
            currentState = .ready(updatedDialogs)
            guard dialog.unreadMessagesCount > 0,
                  defaults.unreadMessagesCount >= dialog.unreadMessagesCount
            else { return }
            let newValue = defaults.unreadMessagesCount - dialog.unreadMessagesCount
            defaults.saveUnreadMessagesCount(newValue)
        }

        private func updateUnreadMessagesCount(with defaults: DefaultsService) {
            guard let dialogs = currentState.dialogs, !dialogs.isEmpty else { return }
            let unreadMessagesCount = dialogs.map(\.unreadMessagesCount).reduce(0, +)
            defaults.saveUnreadMessagesCount(unreadMessagesCount)
        }
    }
}

extension DialogsListScreen.ViewModel {
    enum CurrentState: Equatable {
        case initial
        /// Загрузка с нуля или рефреш
        case loading
        /// Удаление диалога из списка
        case deleteDialog([DialogResponse])
        case ready([DialogResponse])
        case error(ErrorKind)

        var dialogs: [DialogResponse]? {
            if case let .ready(list) = self {
                list
            } else {
                nil
            }
        }

        var isLoading: Bool {
            switch self {
            case .loading, .deleteDialog: true
            default: false
            }
        }

        /// Нужно ли загружать данные, когда их нет (или для рефреша)
        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(dialogList): dialogList.isEmpty
            case .loading, .deleteDialog: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(dialogList): !dialogList.isEmpty
            default: false
            }
        }

        var isReadyAndEmpty: Bool {
            switch self {
            case let .ready(dialogList): dialogList.isEmpty
            default: false
            }
        }
    }
}
