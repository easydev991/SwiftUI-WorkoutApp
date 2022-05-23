import SwiftUI

/// Список дневников
struct JournalsList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = JournalsListViewModel()
    @State private var isCreatingJournal = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var indexToDelete: Int?
    @State private var showDeleteConfirmation = false
    @State private var saveJournalTask: Task<Void, Never>?
    @State private var deleteJournalTask: Task<Void, Never>?
    let userID: Int

    var body: some View {
        ZStack {
            EmptyContentView(mode: .journals)
                .opacity(showEmptyView ? 1 : .zero)
            List {
                ForEach($viewModel.list) { $journal in
                    NavigationLink {
                        JournalEntriesList(userID: userID, journal: $journal)
                    } label: {
                        GenericListCell(for: .journalGroup(journal))
                    }
                }
                .onDelete(perform: initiateDeletion)
                .deleteDisabled(!isMainUser)
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .confirmationDialog(
            Constants.Alert.deleteJournal,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) { deleteJournalButton }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isJournalCreated, perform: closeSheet)
        .sheet(isPresented: $isCreatingJournal) { newJournalSheet }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForJournals() }
        .refreshable { await askForJournals(refresh: true) }
        .toolbar { addJournalButton }
        .onDisappear(perform: cancelTasks)
    }
}

private extension JournalsList {
    var showEmptyView: Bool {
        !defaults.hasJournals && viewModel.list.isEmpty
    }

    var isMainUser: Bool {
        userID == defaults.mainUserID
    }

    var addJournalButton: some View {
        Button(action: showNewJournalSheet) {
            Image(systemName: "plus")
        }
        .opacity(defaults.isAuthorized && isMainUser ? 1 : .zero)
    }

    func showNewJournalSheet() {
        isCreatingJournal.toggle()
    }

    var newJournalSheet: some View {
        SendMessageView(
            text: $viewModel.newJournalTitle,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: !viewModel.canSaveNewJournal,
            sendAction: saveNewJournal,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    func askForJournals(refresh: Bool = false) async {
        await viewModel.makeItems(for: userID, with: defaults, refresh: refresh)
    }

    func saveNewJournal() {
        saveJournalTask = Task {
            await viewModel.createJournal(with: defaults)
        }
    }

    func initiateDeletion(at indexSet: IndexSet) {
        indexToDelete = indexSet.first
        showDeleteConfirmation.toggle()
    }

    var deleteJournalButton: some View {
        Button(role: .destructive) {
            deleteAction(at: indexToDelete)
        } label: {
            Text("Удалить")
        }
    }

    func deleteAction(at index: Int?) {
        deleteJournalTask = Task {
            await viewModel.deleteJournal(at: index, with: defaults)
        }
    }

    func closeSheet(isSuccess: Bool) {
        isCreatingJournal.toggle()
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [saveJournalTask, deleteJournalTask].forEach { $0?.cancel() }
    }
}

struct JournalsList_Previews: PreviewProvider {
    static var previews: some View {
        JournalsList(userID: DefaultsService().mainUserID)
            .environmentObject(DefaultsService())
    }
}
