import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct JournalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var network: NetworkStatus
    @StateObject private var viewModel = JournalSettingsViewModel()
    @State private var journal: JournalResponse
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var saveJournalChangesTask: Task<Void, Never>?
    @FocusState private var isTextFieldFocused: Bool
    private let options = JournalAccess.allCases
    private let updateOnSuccess: (Int) -> Void
    private let initialJournal: JournalResponse

    init(
        with journalToEdit: JournalResponse,
        updatedClbk: @escaping (Int) -> Void
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
        .loadingOverlay(if: viewModel.isLoading)
        .interactiveDismissDisabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isSettingsUpdated, perform: finishSettings)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onDisappear(perform: cancelTask)
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
                    Text($0.description)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var commentsSettings: some View {
        SectionView(headerWithPadding: "Кто может оставлять комментарии", mode: .regular) {
            Picker(
                "Доступ на комментирование",
                selection: $journal.commentAccessType
            ) {
                ForEach(options, id: \.self) {
                    Text($0.description)
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
            await viewModel.editJournalSettings(for: journal, with: defaults)
        }
    }

    var isSaveButtonDisabled: Bool {
        viewModel.isLoading
            || !network.isConnected
            || journal.title.isEmpty
            || initialJournal == journal
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func finishSettings(isSuccess: Bool) {
        if isSuccess {
            updateOnSuccess(journal.id)
            dismiss()
        }
    }

    func cancelTask() {
        saveJournalChangesTask?.cancel()
    }
}

#if DEBUG
struct JournalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalSettingsView(with: .preview, updatedClbk: { _ in })
            .environmentObject(NetworkStatus())
    }
}
#endif
