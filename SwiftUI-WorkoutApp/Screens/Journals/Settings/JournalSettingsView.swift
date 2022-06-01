import SwiftUI

struct JournalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var network: CheckNetworkService
    @StateObject private var viewModel = JournalSettingsViewModel()
    @State private var journal: JournalResponse
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var saveJournalChangesTask: Task<Void, Never>?
    private let options = Constants.JournalAccess.allCases
    private let updateOnSuccess: (Int) -> Void
    private let initialJournal: JournalResponse

    init(
        with journalToEdit: JournalResponse,
        updatedClbk: @escaping (Int) -> Void
    ) {
        initialJournal = journalToEdit
        _journal = .init(initialValue: journalToEdit)
        updateOnSuccess = updatedClbk
    }

    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                headerView
                Form {
                    TextField("Название дневника", text: $journal.title)
                    visibilitySettings
                    commentsSettings
                    saveButton
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .interactiveDismissDisabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isSettingsUpdated, perform: finishSettings)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onDisappear(perform: cancelTask)
    }
}

private extension JournalSettingsView {
    var headerView: some View {
        HeaderForSheet(title: "Настройки дневника")
            .disabled(viewModel.isLoading)
    }

    var visibilitySettings: some View {
        Section("Кто видит записи") {
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
        Section("Кто может оставлять комментарии") {
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
    }

    var saveButton: some View {
        Button(action: saveChanges) {
            ButtonInFormLabel(title: "Сохранить")
        }
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
        updateOnSuccess(journal.id)
        dismiss()
    }

    func cancelTask() {
        saveJournalChangesTask?.cancel()
    }
}

struct JournalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalSettingsView(with: .mock, updatedClbk: {_ in})
            .environmentObject(CheckNetworkService())
    }
}
