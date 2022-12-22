import SwiftUI

/// Список дневников
struct JournalsListView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = JournalsListViewModel()
    @State private var isCreatingJournal = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var journalIdToDelete: Int?
    @State private var journalToEdit: JournalResponse?
    @State private var showDeleteDialog = false
    @State private var updateListTask: Task<Void, Never>?
    @State private var saveJournalTask: Task<Void, Never>?
    @State private var deleteJournalTask: Task<Void, Never>?
    private let userID: Int

    init(for userID: Int) {
        self.userID = userID
    }

    var body: some View {
        Group {
            if viewModel.list.isEmpty {
                emptyContentView
            } else {
                journalsList
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .confirmationDialog(
            Constants.Alert.deleteJournal,
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) { deleteJournalButton }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isJournalCreated, perform: closeSheet)
        .sheet(isPresented: $isCreatingJournal) { newJournalSheet }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .task { await askForJournals() }
        .refreshable { await askForJournals(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                addJournalButton
            }
        }
        .onDisappear(perform: cancelTasks)
    }
}

private extension JournalsListView {
    var refreshButton: some View {
        Button {
            updateListTask = Task {
                await askForJournals()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(showEmptyView ? 1 : .zero)
        .disabled(viewModel.isLoading)
    }

    var addJournalButton: some View {
        Button(action: showNewJournalSheet) {
            Image(systemName: "plus")
        }
        .opacity(showAddJournalButton ? 1 : .zero)
        .disabled(!network.isConnected)
    }

    var emptyContentView: some View {
        EmptyContentView(
            message: "Дневников пока нет",
            buttonTitle: "Создать дневник",
            action: showNewJournalSheet
        )
        .opacity(showEmptyView ? 1 : .zero)
        .disabled(viewModel.isLoading)
    }

    var journalsList: some View {
        List {
            ForEach($viewModel.list) { $journal in
                NavigationLink {
                    JournalEntriesList(for: userID, in: $journal)
                } label: {
                    GenericListCell(
                        for: .journal(
                            info: journal,
                            editClbk: setupJournalToEdit,
                            deleteClbk: initiateDeletion
                        )
                    )
                }
            }
        }
        .sheet(item: $journalToEdit, content: showSettingsSheet)
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
    }

    var showEmptyView: Bool {
        viewModel.list.isEmpty && isMainUser
    }

    var isMainUser: Bool {
        userID == defaults.mainUserID
    }

    var showAddJournalButton: Bool {
        defaults.isAuthorized && isMainUser
    }

    var newJournalSheet: some View {
        SendMessageView(
            header: "Новый дневник",
            text: $viewModel.newJournalTitle,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: !viewModel.canSaveNewJournal,
            sendAction: saveNewJournal,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    var deleteJournalButton: some View {
        Button(role: .destructive) {
            deleteJournalTask = Task {
                await viewModel.delete(journalID: journalIdToDelete, with: defaults)
            }
        } label: {
            Text("Удалить")
        }
    }

    func showNewJournalSheet() {
        isCreatingJournal.toggle()
    }

    func setupJournalToEdit(_ journal: JournalResponse) {
        journalToEdit = journal
    }

    func showSettingsSheet(for journal: JournalResponse) -> some View {
        JournalSettingsView(with: journal, updatedClbk: update)
    }

    func askForJournals(refresh: Bool = false) async {
        await viewModel.makeItems(for: userID, refresh: refresh, with: defaults)
    }

    func saveNewJournal() {
        saveJournalTask = Task {
            await viewModel.createJournal(with: defaults)
        }
    }

    func update(journalID: Int) {
        updateListTask = Task {
            await viewModel.update(journalID: journalID, with: defaults)
        }
    }

    func initiateDeletion(for journalID: Int) {
        journalIdToDelete = journalID
        showDeleteDialog.toggle()
    }

    func closeSheet(isSuccess: Bool) {
        isCreatingJournal.toggle()
        defaults.setUserNeedUpdate(true)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [saveJournalTask, deleteJournalTask, updateListTask].forEach { $0?.cancel() }
    }
}

struct JournalsListView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsListView(for: DefaultsService().mainUserID)
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
