import NetworkStatus
import SwiftUI
import SWModels

/// Экран со списком записей в дневнике
struct JournalEntriesList: View {
    @EnvironmentObject private var network: NetworkStatus
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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.list) {
                    JournalEntryCell(
                        model: $0,
                        reportClbk: { viewModel.reportEntry($0) },
                        canDelete: viewModel.checkIfCanDelete(entry: $0),
                        deleteClbk: initiateDeletion,
                        editClbk: setupEntryToEdit
                    )
                }
            }
            .padding([.top, .horizontal])
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.default, value: viewModel.isLoading)
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
            Button("Ok", action: closeAlert)
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
        .disabled(viewModel.isLoading || !network.isConnected)
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
        viewModel.userID == defaults.mainUserInfo?.userID
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

    func closeNewEntrySheet(isSuccess _: Bool) {
        showEntrySheet.toggle()
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [editAccessTask, deleteEntryTask, updateEntriesTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct JournalEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntriesList(for: 30, in: .constant(.preview))
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif
