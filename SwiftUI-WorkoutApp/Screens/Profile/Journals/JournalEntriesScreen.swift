import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком записей в дневнике
struct JournalEntriesScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var entries = [JournalEntryResponse]()
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var showCreateEntrySheet = false
    @State private var entryIdToDelete: Int?
    @State private var showDeleteDialog = false
    @State private var editEntry: JournalEntryResponse?
    @State private var deleteEntryTask: Task<Void, Never>?
    @State private var updateEntriesTask: Task<Void, Never>?
    private let currentJournal: JournalResponse
    private let userID: Int

    init(for userID: Int, in journal: JournalResponse) {
        self.userID = userID
        self.currentJournal = journal
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(entries) { item in
                    JournalCell(
                        model: .init(journalEntryResponse: item),
                        mode: .entry(
                            editClbk: { editEntry = item },
                            reportClbk: { reportEntry(item) },
                            canDelete: checkIfCanDelete(entry: item),
                            deleteClbk: {
                                entryIdToDelete = item.id
                                showDeleteDialog = true
                            }
                        ),
                        isNetworkConnected: isNetworkConnected,
                        mainUserID: defaults.mainUserInfo?.id,
                        isJournalOwner: userID == defaults.mainUserInfo?.id
                    )
                }
            }
            .padding([.top, .horizontal])
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $editEntry) {
            TextEntryScreen(
                mode: .editJournalEntry(
                    ownerId: userID,
                    editInfo: .init(
                        parentObjectID: currentJournal.id,
                        entryID: $0.id,
                        oldEntry: $0.formattedMessage
                    )
                ),
                refreshClbk: { updateEntries() }
            )
        }
        .confirmationDialog(
            .init(Constants.Alert.deleteJournalEntry),
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) { deleteEntryButton }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok") { errorTitle = "" }
        }
        .task { await askForEntries() }
        .refreshable { await askForEntries(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                refreshButtonIfNeeded
            }
            ToolbarItem(placement: .topBarTrailing) {
                addEntryButtonIfNeeded
            }
        }
        .onDisappear(perform: cancelTasks)
        .navigationTitle(currentJournal.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension JournalEntriesScreen {
    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button(action: updateEntries) {
                Icons.Regular.refresh.view
            }
            .disabled(isLoading)
        }
    }

    @ViewBuilder
    var addEntryButtonIfNeeded: some View {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: userID,
            journalCommentAccess: currentJournal.commentAccessType,
            mainUserId: defaults.mainUserInfo?.id,
            mainUserFriendsIds: defaults.friendsIdsList
        )
        if canCreateEntry {
            Button { showCreateEntrySheet = true } label: {
                Icons.Regular.plus.view
                    .symbolVariant(.circle)
            }
            .disabled(isLoading || !isNetworkConnected)
            .sheet(isPresented: $showCreateEntrySheet) {
                TextEntryScreen(
                    mode: .newForJournal(
                        ownerId: userID,
                        journalId: currentJournal.id
                    ),
                    refreshClbk: { updateEntries() }
                )
            }
        }
    }

    /// Проверяем возможность удаления указанной записи
    ///
    /// Сервер не дает удалить самую первую запись в дневнике
    func checkIfCanDelete(entry: JournalEntryResponse) -> Bool {
        entry.id != entries.map(\.id).min()
    }

    func reportEntry(_ entry: JournalEntryResponse) {
        let complaint = Complaint.journalEntry(
            author: entry.authorName ?? "неизвестен",
            entryText: entry.formattedMessage
        )
        FeedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func updateEntries() {
        showCreateEntrySheet = false
        editEntry = nil
        updateEntriesTask = Task { await askForEntries(refresh: true) }
    }

    func askForEntries(refresh: Bool = false) async {
        if isLoading || !entries.isEmpty, !refresh { return }
        if !refresh { isLoading = true }
        do {
            entries = try await SWClient(with: defaults)
                .getJournalEntries(for: userID, journalID: currentJournal.id)
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    var deleteEntryButton: some View {
        Button(role: .destructive) {
            deleteEntryTask = Task {
                guard let entryID = entryIdToDelete else { return }
                isLoading = true
                do {
                    if try await SWClient(with: defaults).deleteEntry(
                        from: .journal(ownerId: userID, journalId: currentJournal.id),
                        entryID: entryID
                    ) {
                        entries.removeAll(where: { $0.id == entryID })
                    }
                } catch {
                    setupErrorAlert(ErrorFilter.message(from: error))
                }
                isLoading = false
            }
        } label: {
            Text("Удалить")
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func cancelTasks() {
        [deleteEntryTask, updateEntriesTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    JournalEntriesScreen(for: 30, in: .preview)
        .environmentObject(DefaultsService())
}
#endif
