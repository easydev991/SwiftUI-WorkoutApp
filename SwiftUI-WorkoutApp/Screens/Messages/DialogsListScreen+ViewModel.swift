import Foundation
import SWModels
import SWNetworkClient

extension DialogsListScreen {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var currentState = CurrentState.initial
        private let isUITest: Bool
        private let authHelper: AuthHelper
        private let analytics: AnalyticsService

        init(
            isUITest: Bool = false,
            authHelper: AuthHelper,
            analytics: AnalyticsService = AnalyticsService(providers: [NoopAnalyticsProvider()])
        ) {
            self.isUITest = isUITest
            self.authHelper = authHelper
            self.analytics = analytics
        }

        func getDialogs(refresh: Bool = false, defaults: DefaultsService) async {
            guard defaults.isAuthorized else {
                currentState = .initial
                return
            }
            guard currentState.shouldLoad || refresh else {
                return
            }
            if !refresh {
                currentState = .loading
            }
            #if DEBUG
            let client: MessagesClient = isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: authHelper)
            #else
            let client: MessagesClient = SWClient(with: authHelper)
            #endif
            do {
                let dialogs = try await client.getDialogs()
                currentState = .ready(dialogs)
                updateUnreadMessagesCount(with: defaults)
            } catch ClientError.noConnection {
                analytics.log(.appError(kind: .dialogsLoadFailed, error: ClientError.noConnection))
                currentState = .error(.notConnected)
            } catch {
                analytics.log(.appError(kind: .dialogsLoadFailed, error: error))
                currentState = .error(.common(message: error.localizedDescription))
            }
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
            if case let .ready(list) = self { list } else { nil }
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
