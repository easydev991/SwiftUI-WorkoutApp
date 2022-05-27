import SwiftUI

/// Экран со списком записей в дневнике
struct JournalEntriesList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: JournalEntriesListViewModel
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var showAccessSettings = false
    @State private var showEntrySheet = false
    @State private var indexToDelete: Int?
    @State private var showDeleteConfirmation = false
    @State private var needUpdateJournal = false
    @State private var editAccessTask: Task<Void, Never>?
    @State private var saveNewEntryTask: Task<Void, Never>?
    @State private var deleteEntryTask: Task<Void, Never>?
    @State private var updateJournalTask: Task<Void, Never>?

    init(for userID: Int, in journal: Binding<JournalResponse>) {
        _viewModel = StateObject(
            wrappedValue: .init(
                for: userID,
                with: journal.wrappedValue
            )
        )
    }

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.list) {
#warning("TODO: добавить редактирование записи")
                    JournalEntryCell(entry: $0)
                }
                .onDelete(perform: initiateDeletion)
                .deleteDisabled(!isMainUser)
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .confirmationDialog(
            Constants.Alert.deleteJournalEntry,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) { deleteEntryButton }
        .onChange(of: viewModel.isSettingsUpdated, perform: closeSettingsSheet)
        .onChange(of: viewModel.isEntryCreated, perform: closeNewEntrySheet)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: needUpdateJournal, perform: updateJournal)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForEntries() }
        .refreshable { await askForEntries(refresh: true) }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isMainUser {
                    Group {
                        settingsButton
                        addEntryButton
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onDisappear(perform: cancelTasks)
        .navigationTitle(viewModel.currentJournal.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension JournalEntriesList {
    var settingsButton: some View {
        Button(action: showSettings) {
            Image(systemName: "gearshape.fill")
        }
        .sheet(isPresented: $showAccessSettings) {
            JournalSettingsView(
                with: viewModel.currentJournal,
                needUpdate: $needUpdateJournal
            )
        }
    }

    func showSettings() {
        showAccessSettings.toggle()
    }

    func closeSettingsSheet(isSuccess: Bool) {
        showAccessSettings.toggle()
    }

    func updateJournal(isSuccess: Bool) {
        updateJournalTask = Task {
            await viewModel.updateJournal(with: defaults)
        }
    }

    var addEntryButton: some View {
        Button(action: showNewEntry) {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showEntrySheet) { newEntrySheet }
    }

    func showNewEntry() {
        showEntrySheet.toggle()
    }

    var newEntrySheet: some View {
        SendMessageView(
            text: $viewModel.newEntryText,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: !viewModel.canSaveNewEntry,
            sendAction: saveNewEntry,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    var isMainUser: Bool {
        viewModel.userID == defaults.mainUserID
    }

    func askForEntries(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
    }

    func saveNewEntry() {
        saveNewEntryTask = Task {
            await viewModel.saveNewEntry(with: defaults)
        }
    }

    func initiateDeletion(at indexSet: IndexSet) {
        indexToDelete = indexSet.first
        showDeleteConfirmation.toggle()
    }

    var deleteEntryButton: some View {
        Button(role: .destructive) {
            deleteAction(at: indexToDelete)
        } label: {
            Text("Удалить")
        }
    }

    func deleteAction(at index: Int?) {
        deleteEntryTask = Task {
            await viewModel.deleteEntry(at: index, with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeNewEntrySheet(isSuccess: Bool) {
        showEntrySheet.toggle()
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [editAccessTask, saveNewEntryTask, deleteEntryTask, updateJournalTask].forEach { $0?.cancel() }
    }
}

struct JournalEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntriesList(for: DefaultsService().mainUserID, in: .constant(.mock))
            .environmentObject(DefaultsService())
    }
}
