import SwiftUI

/// Экран со списком записей в дневнике
struct JournalEntriesList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = JournalEntriesListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var showAccessSettings = false
    @State private var showEntrySheet = false
    @State private var indexToDelete: Int?
    @State private var showDeleteConfirmation = false
    @State private var editAccessTask: Task<Void, Never>?
    @State private var saveNewEntryTask: Task<Void, Never>?
    @State private var deleteEntryTask: Task<Void, Never>?
    let userID: Int
    let journal: JournalResponse

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.list) {
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
        .onChange(of: viewModel.isEntryCreated, perform: closeNewEntrySheet)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForEntries() }
        .refreshable { await askForEntries(refresh: true) }
        .sheet(isPresented: $showEntrySheet) { newEntrySheet }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isMainUser {
                    settingsButton
                    addEntryButton
                }
            }
        }
        .onDisappear(perform: cancelTasks)
        .navigationTitle(journal.title.valueOrEmpty)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension JournalEntriesList {
    var settingsButton: some View {
        Button(action: showSettings) {
            Image(systemName: "gearshape.fill")
        }
    }

    func showSettings() {
#warning("TODO: сверстать экран с настройками доступа дневника")
        showAccessSettings.toggle()
    }

    var addEntryButton: some View {
        Button(action: showNewEntry) {
            Image(systemName: "plus")
        }
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
        userID == defaults.mainUserID
    }

    func askForEntries(refresh: Bool = false) async {
        await viewModel.makeItems(
            for: userID,
            journalID: journal.id,
            with: defaults,
            refresh: refresh
        )
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
        [editAccessTask, saveNewEntryTask, deleteEntryTask].forEach { $0?.cancel() }
    }
}

struct JournalEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntriesList(userID: DefaultsService().mainUserID, journal: .mock)
            .environmentObject(DefaultsService())
    }
}
