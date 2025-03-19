import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком записей в дневнике
struct JournalEntriesScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var currentState = CurrentState.initial
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
            contentView
                .animation(.default, value: currentState)
                .padding([.top, .horizontal])
        }
        .loadingOverlay(if: currentState.isLoading)
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
    enum CurrentState: Equatable {
        case initial
        case loading
        case saveEntryAction([JournalEntryResponse])
        case deleteEntryAction([JournalEntryResponse])
        case ready([JournalEntryResponse])
        case error(ErrorKind)

        var isLoading: Bool {
            switch self {
            case .loading, .saveEntryAction, .deleteEntryAction: true
            default: false
            }
        }

        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(entries): entries.isEmpty
            case .loading, .saveEntryAction, .deleteEntryAction: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(entries): !entries.isEmpty
            default: false
            }
        }
    }

    var mainUserId: Int? { defaults.mainUserInfo?.id }
    var isMainUser: Bool { userID == mainUserId }

    @ViewBuilder
    var contentView: some View {
        switch currentState {
        case let .ready(entries), let .saveEntryAction(entries), let .deleteEntryAction(entries):
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
                        mainUserID: mainUserId,
                        isJournalOwner: isMainUser && mainUserId == currentJournal.ownerID
                    )
                }
            }
        case let .error(errorKind):
            CommonErrorView(errorKind: errorKind)
        case .initial, .loading:
            ContainerRelativeView {
                Text("Загрузка...")
            }
        }
    }

    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button(action: updateEntries) {
                Icons.Regular.refresh.view
            }
            .disabled(currentState.isLoading)
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
            .disabled(currentState.isLoading)
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
        guard case let .ready(entries) = currentState else { return false }
        return entry.id != entries.map(\.id).min()
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
        guard case let .ready(entries) = currentState else { return }
        currentState = .saveEntryAction(entries)
        updateEntriesTask = Task { await askForEntries(refresh: true) }
    }

    func askForEntries(refresh: Bool = false) async {
        let needUpdateMainUser = isMainUser ? defaults.needUpdateUser : false
        guard currentState.shouldLoad || needUpdateMainUser || refresh else { return }
        guard isNetworkConnected else {
            if currentState.isReadyAndNotEmpty {
                SWAlert.shared.presentNoConnection(false)
            } else {
                currentState = .error(.notConnected)
            }
            return
        }
        if !refresh {
            currentState = .loading
        }
        do {
            let entries = try await SWClient(with: defaults).getJournalEntries(
                for: userID,
                journalID: currentJournal.id
            )
            currentState = .ready(entries)
        } catch {
            currentState = .error(.common(message: error.localizedDescription))
        }
    }

    var deleteEntryButton: some View {
        Button(role: .destructive) {
            guard let entryID = entryIdToDelete else { return }
            guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
            guard case let .ready(entries) = currentState else { return }
            deleteEntryTask = Task {
                currentState = .deleteEntryAction(entries)
                do {
                    try await SWClient(with: defaults).deleteEntry(
                        from: .journal(ownerId: userID, journalId: currentJournal.id),
                        entryID: entryID
                    )
                    defaults.setUserNeedUpdate(true)
                    let updatedList = entries.filter { $0.id != entryID }
                    currentState = .ready(updatedList)
                } catch {
                    currentState = .ready(entries)
                    SWAlert.shared.presentDefaultUIKit(error)
                }
            }
        } label: {
            Text("Удалить")
        }
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
