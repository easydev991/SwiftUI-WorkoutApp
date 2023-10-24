import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Список дневников
struct JournalsListView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var journals = [JournalResponse]()
    @State private var newJournalTitle = ""
    @State private var isLoading = false
    @State private var isCreatingJournal = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var journalIdToDelete: Int?
    @State private var journalToEdit: JournalResponse?
    @State private var showDeleteDialog = false
    @State private var updateListTask: Task<Void, Never>?
    @State private var saveJournalTask: Task<Void, Never>?
    @State private var deleteJournalTask: Task<Void, Never>?
    let userID: Int

    var body: some View {
        journalsList
            .overlay { emptyContentView }
            .loadingOverlay(if: isLoading)
            .background(Color.swBackground)
            .confirmationDialog(
                .init(Constants.Alert.deleteJournal),
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) { deleteJournalButton }
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
                await askForJournals(refresh: true)
            }
        } label: {
            Image(systemName: Icons.Regular.refresh.rawValue)
        }
        .opacity(refreshButtonOpacity)
        .disabled(isLoading)
    }

    var refreshButtonOpacity: CGFloat {
        showEmptyView || !DeviceOSVersionChecker.iOS16Available ? 1 : 0
    }

    var addJournalButton: some View {
        Button(action: showNewJournalSheet) {
            Image(systemName: Icons.Regular.plus.rawValue)
        }
        .opacity(showAddJournalButton ? 1 : 0)
        .disabled(!network.isConnected)
    }

    var emptyContentView: some View {
        EmptyContentView(
            mode: .journals,
            isAuthorized: defaults.isAuthorized,
            hasFriends: defaults.hasFriends,
            hasSportsGrounds: defaults.hasSportsGrounds,
            isNetworkConnected: network.isConnected,
            action: showNewJournalSheet
        )
        .opacity(showEmptyView ? 1 : 0)
    }

    var journalsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(journals) { journal in
                    NavigationLink {
                        JournalEntriesList(for: userID, in: journal)
                    } label: {
                        JournalCell(
                            model: .init(journalResponse: journal),
                            mode: .root(
                                setupClbk: { setupJournalToEdit(journal) },
                                deleteClbk: { initiateDeletion(for: journal.id) }
                            ),
                            isNetworkConnected: network.isConnected,
                            mainUserID: defaults.mainUserInfo?.userID,
                            isJournalOwner: journal.ownerID == defaults.mainUserInfo?.userID
                        )
                    }
                }
            }
            .padding([.top, .horizontal])
        }
        .sheet(item: $journalToEdit, content: showSettingsSheet)
    }

    var showEmptyView: Bool {
        journals.isEmpty && isMainUser && !isLoading
    }

    var isMainUser: Bool {
        userID == defaults.mainUserInfo?.userID
    }

    var showAddJournalButton: Bool {
        defaults.isAuthorized && isMainUser
    }

    var newJournalSheet: some View {
        SendMessageView(
            header: "Новый дневник",
            placeholder: "Создай первую запись в дневнике",
            text: $newJournalTitle,
            isLoading: isLoading,
            isSendButtonDisabled: !canSaveNewJournal,
            sendAction: saveNewJournal,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    var canSaveNewJournal: Bool { !isLoading && !newJournalTitle.isEmpty }

    var deleteJournalButton: some View {
        Button(role: .destructive) {
            deleteJournalTask = Task {
                guard let journalID = journalIdToDelete, !isLoading else { return }
                isLoading = true
                do {
                    if try await SWClient(with: defaults).deleteJournal(journalID: journalID) {
                        journals.removeAll(where: { $0.id == journalID })
                        defaults.setUserNeedUpdate(true)
                    }
                } catch {
                    setupErrorAlert(with: ErrorFilter.message(from: error))
                }
                isLoading = false
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
        if isLoading || !journals.isEmpty, !refresh { return }
        if !refresh { isLoading = true }
        do {
            journals = try await SWClient(with: defaults).getJournals(for: userID)
        } catch {
            setupErrorAlert(with: ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func saveNewJournal() {
        isLoading = true
        saveJournalTask = Task {
            do {
                if try await SWClient(with: defaults).createJournal(with: newJournalTitle) {
                    newJournalTitle = ""
                    isCreatingJournal.toggle()
                    defaults.setUserNeedUpdate(true)
                    await askForJournals(refresh: true)
                }
            } catch {
                setupErrorAlert(with: ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func update(journal: JournalResponse) {
        journalToEdit = nil
        if let index = journals.firstIndex(where: { $0.id == journal.id }) {
            journals[index] = journal
        }
    }

    func initiateDeletion(for journalID: Int) {
        journalIdToDelete = journalID
        showDeleteDialog.toggle()
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() { errorTitle = "" }

    func cancelTasks() {
        [saveJournalTask, deleteJournalTask, updateListTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    JournalsListView(userID: .previewUserID)
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
