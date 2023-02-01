import SwiftUI

/// Экран для создания и изменения текстовой записи (комментарий к площадке, мерпориятию или дневнику)
struct TextEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = TextEntryViewModel()
    @State private var entryText = ""
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var addEntryTask: Task<Void, Never>?
    @State private var editEntryTask: Task<Void, Never>?
    @FocusState private var isFocused

    private let mode: Mode
    private var oldEntryText: String?
    private let refreshClbk: () -> Void

    init(mode: Mode, refreshClbk: @escaping () -> Void) {
        self.mode = mode
        self.refreshClbk = refreshClbk
        switch mode {
        case let .editGround(info),
            let .editEvent(info),
            let .editJournalEntry(info):
            self.oldEntryText = info.oldEntry
        default: break
        }
    }

    var body: some View {
        content
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.isSuccess, perform: dismissOnSuccess)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onAppear(perform: setupOldEntryIfNeeded)
        .onDisappear(perform: cancelTasks)
    }
}

extension TextEntryView {
    enum Mode {
        case newForGround(id: Int)
        case newForEvent(id: Int)
        case newForJournal(id: Int)
        case editGround(EditInfo)
        case editEvent(EditInfo)
        case editJournalEntry(EditInfo)

        struct EditInfo {
            let parentObjectID, entryID: Int
            let oldEntry: String
        }
    }
}

private extension TextEntryView.Mode {
    var headerTitle: String {
        switch self {
        case .newForEvent, .newForGround:
            return "Новый комментарий"
        case .editEvent, .editGround:
            return "Изменить комментарий"
        case .newForJournal:
            return "Новая запись"
        case .editJournalEntry:
            return "Изменить запись"
        }
    }
}

private extension TextEntryView {
    var content: some View {
        SendMessageView(
            header: mode.headerTitle,
            text: $entryText,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: !canSend,
            sendAction: sendAction,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    func sendAction() {
        switch mode {
        case .newForGround, .newForEvent, .newForJournal:
            addEntryTask = Task {
                await viewModel.addNewEntry(
                    mode,
                    entryText: entryText,
                    defaults: defaults
                )
            }
        case .editGround, .editEvent, .editJournalEntry:
            editEntryTask = Task {
                await viewModel.editEntry(
                    for: mode,
                    entryText: entryText,
                    with: defaults
                )
            }
        }
        isFocused.toggle()
    }

    func dismissOnSuccess(isSuccess _: Bool) {
        refreshClbk()
        dismiss()
    }

    func closeAlert() {
        viewModel.closedErrorAlert()
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func showKeyboard() {
        guard !isFocused else { return }
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 750_000_000)
            isFocused = true
        }
    }

    func setupOldEntryIfNeeded() {
        if let oldEntry = oldEntryText {
            entryText = oldEntry
        }
    }

    var canSend: Bool {
        switch mode {
        case .newForGround, .newForEvent, .newForJournal:
            return !entryText.isEmpty && !viewModel.isLoading
        case .editGround, .editEvent, .editJournalEntry:
            return entryText != oldEntryText && !viewModel.isLoading
        }
    }

    func cancelTasks() {
        [addEntryTask, editEntryTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        TextEntryView(mode: .newForGround(id: .zero), refreshClbk: {})
            .environmentObject(DefaultsService())
    }
}
#endif
