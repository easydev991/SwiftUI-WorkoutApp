import SwiftUI

/// Экран со списком записей в дневнике
struct JournalEntriesList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: JournalEntriesListViewModel
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var showEntrySheet = false
    @State private var entryIdToDelete: Int?
    @State private var showDeleteDialog = false
    @State private var editEntry: JournalEntryResponse?
    @State private var editAccessTask: Task<Void, Never>?
    @State private var deleteEntryTask: Task<Void, Never>?
    @State private var updateEntriesTask: Task<Void, Never>?

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
                    JournalEntryCell(
                        model: $0,
                        deleteClbk: initiateDeletion,
                        editClbk: setupEntryToEdit
                    )
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .sheet(item: $editEntry) {
            TextEntryView(
                mode: .editJournalEntry(
                    .init(
                        parentObjectID: viewModel.currentJournal.id,
                        entryID: $0.id,
                        oldEntry: $0.formattedMessage
                    )
                ),
                refreshClbk: updateEntries
            )
        }
        .confirmationDialog(
            Constants.Alert.deleteJournalEntry,
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) { deleteEntryButton }
        .onChange(of: viewModel.isEntryCreated, perform: closeNewEntrySheet)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForEntries() }
        .refreshable { await askForEntries(refresh: true) }
        .toolbar {
            if isMainUser {
                addEntryButton
            }
        }
        .onDisappear(perform: cancelTasks)
        .navigationTitle(viewModel.currentJournal.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension JournalEntriesList {
    func setupEntryToEdit(_ entry: JournalEntryResponse) {
        editEntry = entry
    }

    func updateEntries() {
        updateEntriesTask = Task {
            await viewModel.makeItems(with: defaults, refresh: true)
        }
    }

    var addEntryButton: some View {
        Button(action: showNewEntry) {
            Image(systemName: "plus")
        }
        .disabled(viewModel.isLoading)
        .sheet(isPresented: $showEntrySheet) {
            TextEntryView(
                mode: .newForJournal(id: viewModel.currentJournal.id),
                refreshClbk: updateEntries
            )
        }
    }

    func showNewEntry() {
        showEntrySheet.toggle()
    }

    var isMainUser: Bool {
        viewModel.userID == defaults.mainUserID
    }

    func askForEntries(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
    }

    func initiateDeletion(for id: Int) {
        entryIdToDelete = id
        showDeleteDialog.toggle()
    }

    var deleteEntryButton: some View {
        Button(role: .destructive) {
            deleteEntryTask = Task {
                await viewModel.delete(entryIdToDelete, with: defaults)
            }
        } label: {
            Text("Удалить")
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
        [editAccessTask, deleteEntryTask, updateEntriesTask].forEach { $0?.cancel() }
    }
}

struct JournalEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntriesList(for: DefaultsService().mainUserID, in: .constant(.mock))
            .environmentObject(DefaultsService())
    }
}
