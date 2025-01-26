import SwiftUI
import SWNetworkClient

/// Экран для создания и изменения текстовой записи (комментарий к площадке, мерпориятию или дневнику)
struct TextEntryScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var entryText = ""
    @State private var errorTitle = ""
    @State private var saveEntryTask: Task<Void, Never>?
    private let mode: Mode
    private let oldEntryText: String?
    private let refreshClbk: () -> Void

    init(mode: Mode, refreshClbk: @escaping () -> Void) {
        self.mode = mode
        self.refreshClbk = refreshClbk
        switch mode {
        case let .editPark(info),
             let .editEvent(info),
             let .editJournalEntry(_, info):
            self.oldEntryText = info.oldEntry
        default:
            self.oldEntryText = nil
        }
    }

    var body: some View {
        SendMessageScreen(
            header: mode.headerTitle,
            placeholder: mode.placeholder,
            text: $entryText,
            isLoading: isLoading,
            isSendButtonDisabled: !canSend,
            sendAction: sendAction,
            errorTitle: $errorTitle,
            dismissError: { setupErrorAlert("") }
        )
        .onAppear {
            if let oldEntryText {
                entryText = oldEntryText
            }
        }
        .onDisappear { saveEntryTask?.cancel() }
    }
}

extension TextEntryScreen {
    enum Mode {
        case newForPark(id: Int)
        case newForEvent(id: Int)
        case newForJournal(ownerId: Int, journalId: Int)
        case editPark(EditInfo)
        case editEvent(EditInfo)
        case editJournalEntry(ownerId: Int, editInfo: EditInfo)

        struct EditInfo {
            let parentObjectID, entryID: Int
            let oldEntry: String
        }
    }
}

private extension TextEntryScreen.Mode {
    var headerTitle: LocalizedStringKey {
        switch self {
        case .newForEvent, .newForPark:
            "Новый комментарий"
        case .editEvent, .editPark:
            "Изменить комментарий"
        case .newForJournal:
            "Новая запись"
        case .editJournalEntry:
            "Изменить запись"
        }
    }

    var placeholder: String? {
        switch self {
        case .newForJournal:
            "Создай новую запись в дневнике"
        default:
            nil
        }
    }
}

private extension TextEntryScreen {
    func sendAction() {
        isLoading = true
        saveEntryTask = Task {
            do {
                let client = SWClient(with: defaults)
                let isSuccess: Bool = switch mode {
                case let .newForPark(id):
                    try await client.addNewEntry(
                        to: .park(id: id), entryText: entryText
                    )
                case let .newForEvent(id):
                    try await client.addNewEntry(
                        to: .event(id: id), entryText: entryText
                    )
                case let .newForJournal(ownerId, journalId):
                    try await client.addNewEntry(
                        to: .journal(ownerId: ownerId, journalId: journalId),
                        entryText: entryText
                    )
                case let .editPark(info):
                    try await client.editEntry(
                        for: .park(id: info.parentObjectID),
                        entryID: info.entryID,
                        newEntryText: entryText
                    )
                case let .editEvent(info):
                    try await client.editEntry(
                        for: .event(id: info.parentObjectID),
                        entryID: info.entryID,
                        newEntryText: entryText
                    )
                case let .editJournalEntry(ownerId, info):
                    try await client.editEntry(
                        for: .journal(ownerId: ownerId, journalId: info.parentObjectID),
                        entryID: info.entryID,
                        newEntryText: entryText
                    )
                }
                if isSuccess { refreshClbk() }
            } catch {
                setupErrorAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(_ message: String) {
        errorTitle = message
    }

    var canSend: Bool {
        switch mode {
        case .newForPark, .newForEvent, .newForJournal:
            !entryText.isEmpty
        case .editPark, .editEvent, .editJournalEntry:
            entryText != oldEntryText
        }
    }
}

#if DEBUG
#Preview {
    TextEntryScreen(mode: .newForPark(id: 0), refreshClbk: {})
        .environmentObject(DefaultsService())
}
#endif
