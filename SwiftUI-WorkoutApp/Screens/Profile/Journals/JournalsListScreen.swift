import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Список дневников
struct JournalsListScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var currentState = CurrentState.initial
    @State private var newJournalTitle = ""
    @State private var isCreatingJournal = false
    @State private var journalIdToDelete: Int?
    @State private var journalToEdit: JournalResponse?
    @State private var showDeleteDialog = false
    @State private var updateListTask: Task<Void, Never>?
    @State private var saveJournalTask: Task<Void, Never>?
    @State private var deleteJournalTask: Task<Void, Never>?
    let userId: Int

    var body: some View {
        ScrollView {
            contentView
                .animation(.default, value: currentState)
                .frame(maxWidth: .infinity)
                .padding([.top, .horizontal])
                .sheet(item: $journalToEdit, content: showSettingsSheet)
        }
        .overlay {
            EmptyContentView(
                mode: .journals,
                action: showNewJournalSheet
            )
            .opacity(currentState.showEmptyView(isMainUser: isMainUser) ? 1 : 0)
        }
        .loadingOverlay(if: currentState.isLoading)
        .background(Color.swBackground)
        .confirmationDialog(
            .init(Strings.Alert.deleteJournal),
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            deleteJournalButton
        }
        .sheet(isPresented: $isCreatingJournal) { newJournalSheet }
        .task { await askForJournals() }
        .refreshable { await askForJournals(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                addJournalButton
            }
        }
        .onDisappear(perform: cancelTasks)
    }
}

private extension JournalsListScreen {
    enum CurrentState: Equatable {
        case initial
        case loading
        case saveJournalAction([JournalResponse])
        case deleteJournalAction([JournalResponse])
        case ready([JournalResponse])
        case error(ErrorKind)

        var isLoading: Bool {
            switch self {
            case .loading, .saveJournalAction, .deleteJournalAction: true
            default: false
            }
        }

        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(journals): journals.isEmpty
            case .loading, .saveJournalAction, .deleteJournalAction: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(journals): !journals.isEmpty
            default: false
            }
        }

        func showEmptyView(isMainUser: Bool) -> Bool {
            if case let .ready(list) = self, isMainUser {
                list.isEmpty
            } else {
                false
            }
        }
    }

    @ViewBuilder
    var addJournalButton: some View {
        if showAddJournalButton {
            Button(action: showNewJournalSheet) {
                Icons.Regular.plus.view
                    .symbolVariant(.circle)
            }
            .tint(.accent)
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch currentState {
        case let .ready(journals), let .saveJournalAction(journals), let .deleteJournalAction(journals):
            LazyVStack(spacing: 12) {
                ForEach(journals) { journal in
                    NavigationLink {
                        JournalEntriesScreen(for: userId, in: journal)
                    } label: {
                        JournalCell(
                            model: .init(journalResponse: journal),
                            mode: .root(
                                setupClbk: { setupJournalToEdit(journal) },
                                deleteClbk: { initiateDeletion(for: journal.id) }
                            ),
                            mainUserId: defaults.mainUserInfo?.id,
                            isJournalOwner: journal.ownerId == defaults.mainUserInfo?.id
                        )
                    }
                }
            }
        case let .error(errorKind):
            CommonErrorView(errorKind: errorKind)
        case .initial, .loading:
            Color.swBackground
        }
    }

    var isMainUser: Bool {
        userId == defaults.mainUserInfo?.id
    }

    var showAddJournalButton: Bool {
        defaults.isAuthorized && isMainUser
    }

    var newJournalSheet: some View {
        SendMessageScreen(
            header: "Новый дневник",
            placeholder: "Создай первую запись в дневнике",
            text: $newJournalTitle,
            isLoading: currentState.isLoading,
            isSendButtonDisabled: !canSaveNewJournal,
            sendAction: saveNewJournal
        )
    }

    var canSaveNewJournal: Bool {
        !currentState.isLoading && !newJournalTitle.isEmpty
    }

    var deleteJournalButton: some View {
        Button(role: .destructive) {
            guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
            guard let journalId = journalIdToDelete else { return }
            guard case let .ready(journals) = currentState else { return }
            deleteJournalTask = Task {
                currentState = .deleteJournalAction(journals)
                do {
                    #if DEBUG
                    let client: JournalsClient = Constants.isUITest
                        ? MockSWClient(instantResponse: true)
                        : SWClient(with: defaults.authHelper)
                    #else
                    let client: JournalsClient = SWClient(with: defaults.authHelper)
                    #endif
                    try await client.deleteJournal(
                        with: journalId,
                        for: defaults.mainUserInfo?.id
                    )
                    defaults.setUserNeedUpdate(true)
                    let updatedList = journals.filter { $0.id != journalId }
                    currentState = .ready(updatedList)
                } catch {
                    currentState = .ready(journals)
                    SWAlert.shared.presentDefaultUIKit(error)
                }
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
        JournalSettingsScreen(with: journal, updatedClbk: update)
    }

    func askForJournals(refresh: Bool = false) async {
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
            #if DEBUG
            let client: JournalsClient = Constants.isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: defaults.authHelper)
            #else
            let client: JournalsClient = SWClient(with: defaults.authHelper)
            #endif
            let journals = try await client.getJournals(for: userId)
            currentState = .ready(journals)
        } catch {
            currentState = .error(.common(message: error.localizedDescription))
        }
    }

    func saveNewJournal() {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        guard case let .ready(journals) = currentState else { return }
        currentState = .saveJournalAction(journals)
        saveJournalTask = Task {
            do {
                #if DEBUG
                let client: JournalsClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: JournalsClient = SWClient(with: defaults.authHelper)
                #endif
                try await client.createJournal(
                    with: newJournalTitle,
                    for: defaults.mainUserInfo?.id
                )
                newJournalTitle = ""
                isCreatingJournal.toggle()
                defaults.setUserNeedUpdate(true)
                await askForJournals(refresh: true)
            } catch {
                currentState = .ready(journals)
                SWAlert.shared.presentDefaultUIKit(error)
            }
        }
    }

    func update(journal: JournalResponse) {
        journalToEdit = nil
        if case let .ready(journals) = currentState,
           let index = journals.firstIndex(where: { $0.id == journal.id }) {
            var updatedList = journals
            updatedList[index] = journal
            currentState = .ready(updatedList)
        }
    }

    func initiateDeletion(for journalId: Int) {
        journalIdToDelete = journalId
        showDeleteDialog.toggle()
    }

    func cancelTasks() {
        [saveJournalTask, deleteJournalTask, updateListTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    JournalsListScreen(userId: .previewUserId)
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
        .networkStatus(true)
}
#endif
