import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с настройками дневника
struct JournalSettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @State private var journal: JournalResponse
    @State private var isLoading = false
    @State private var saveJournalChangesTask: Task<Void, Never>?
    @FocusState private var isTextFieldFocused: Bool
    private let options = JournalAccess.allCases
    private let updateOnSuccess: (JournalResponse) -> Void
    private let initialJournal: JournalResponse

    init(
        with journalToEdit: JournalResponse,
        updatedClbk: @escaping (JournalResponse) -> Void
    ) {
        self.initialJournal = journalToEdit
        _journal = .init(initialValue: journalToEdit)
        self.updateOnSuccess = updatedClbk
    }

    var body: some View {
        ContentInSheet(title: "Настройки дневника", spacing: 0) {
            VStack(spacing: 22) {
                journalTitleTextField
                visibilitySettings
                commentsSettings
                saveButton
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding([.top, .horizontal])
        }
        .loadingOverlay(if: isLoading)
        .interactiveDismissDisabled(isLoading)
        .onDisappear { saveJournalChangesTask?.cancel() }
    }
}

private extension JournalSettingsScreen {
    var journalTitleTextField: some View {
        SWTextField(
            placeholder: "Название дневника",
            text: $journal.title,
            isFocused: isTextFieldFocused
        )
        .focused($isTextFieldFocused)
    }

    var visibilitySettings: some View {
        SectionView(headerWithPadding: "Кто видит записи", mode: .regular) {
            Picker(
                "Доступ на просмотр",
                selection: $journal.viewAccessType
            ) {
                ForEach(options, id: \.self) {
                    Text(.init($0.description))
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var commentsSettings: some View {
        SectionView(headerWithPadding: "Кто может оставлять комментарии", mode: .regular) {
            Picker("Доступ на комментирование", selection: $journal.commentAccessType) {
                ForEach(options, id: \.self) {
                    Text(.init($0.description))
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.bottom, 20)
    }

    var saveButton: some View {
        Button("Сохранить", action: saveChanges)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .disabled(isSaveButtonDisabled)
    }

    func saveChanges() {
        saveJournalChangesTask = Task {
            isLoading = true
            do {
                let isSuccess = try await SWClient(with: defaults).editJournalSettings(
                    with: journal.id,
                    title: journal.title,
                    for: defaults.mainUserInfo?.id,
                    viewAccess: journal.viewAccessType,
                    commentAccess: journal.commentAccessType
                )
                if isSuccess {
                    updateOnSuccess(journal)
                }
            } catch {
                SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
            }
            isLoading.toggle()
        }
    }

    var isSaveButtonDisabled: Bool {
        !isNetworkConnected
            || journal.title.isEmpty
            || initialJournal == journal
    }
}

#if DEBUG
#Preview {
    JournalSettingsScreen(with: .preview, updatedClbk: { _ in })
}
#endif
