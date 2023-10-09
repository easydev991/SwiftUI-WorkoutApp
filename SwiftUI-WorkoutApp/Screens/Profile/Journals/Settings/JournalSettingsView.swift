import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels
import SWNetworkClient

struct JournalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var network: NetworkStatus
    @State private var journal: JournalResponse
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
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
        ContentInSheet(title: "Настройки дневника", spacing: .zero) {
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
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { alertMessage = "" }
        }
        .onDisappear { saveJournalChangesTask?.cancel() }
    }
}

private extension JournalSettingsView {
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
                if try await SWClient(with: defaults).editJournalSettings(
                    for: journal.id,
                    title: journal.title,
                    viewAccess: journal.viewAccessType,
                    commentAccess: journal.commentAccessType
                ) {
                    updateOnSuccess(journal)
                }
            } catch {
                let message = ErrorFilter.message(from: error)
                showErrorAlert = !message.isEmpty
                alertMessage = message
            }
            isLoading.toggle()
        }
    }

    var isSaveButtonDisabled: Bool {
        !network.isConnected
            || journal.title.isEmpty
            || initialJournal == journal
    }
}

#if DEBUG
#Preview {
    JournalSettingsView(with: .preview, updatedClbk: { _ in })
        .environmentObject(NetworkStatus())
}
#endif
