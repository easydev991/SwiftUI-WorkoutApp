import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком диалогов
struct DialogsListScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var dialogs = [DialogResponse]()
    @State private var selectedDialog: DialogResponse?
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var indexToDelete: Int?
    @State private var openFriendList = false
    @State private var showDeleteConfirmation = false
    @State private var refreshTask: Task<Void, Never>?
    @State private var deleteDialogTask: Task<Void, Never>?

    var body: some View {
        dialogList
            .overlay { emptyContentView }
            .loadingOverlay(if: isLoading)
            .background(Color.swBackground)
            .confirmationDialog(
                .init(Constants.Alert.deleteDialog),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) { deleteDialogButton }
            .alert(errorTitle, isPresented: $showErrorAlert) {
                Button("Ok") { errorTitle = "" }
            }
            .task { await askForDialogs() }
            .refreshable { await askForDialogs(refresh: true) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    refreshButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    friendListButton
                }
            }
            .onDisappear {
                [refreshTask, deleteDialogTask].forEach { $0?.cancel() }
            }
    }
}

private extension DialogsListScreen {
    var refreshButton: some View {
        Button {
            refreshTask = Task {
                await askForDialogs(refresh: true)
            }
        } label: {
            Icons.Regular.refresh.view
        }
        .opacity(showEmptyView || !DeviceOSVersionChecker.iOS16Available ? 1 : 0)
        .disabled(isLoading)
    }

    var friendListButton: some View {
        NavigationLink(isActive: $openFriendList) {
            if hasFriends, let mainUserID = defaults.mainUserInfo?.id {
                UsersListScreen(mode: .friendsForChat(userID: mainUserID))
            } else {
                SearchUsersScreen(mode: .chat)
            }
        } label: {
            Icons.Regular.plus.view
                .symbolVariant(.circle)
        }
        .opacity(hasFriends || !dialogs.isEmpty ? 1 : 0)
        .disabled(!isNetworkConnected)
    }

    var emptyContentView: some View {
        EmptyContentView(
            mode: .dialogs,
            action: emptyViewAction
        )
        .opacity(showEmptyView ? 1 : 0)
    }

    var showEmptyView: Bool {
        dialogs.isEmpty && !isLoading
    }

    @ViewBuilder
    var dialogList: some View {
        ZStack {
            Color.swBackground
            List {
                ForEach(dialogs) { model in
                    dialogListItem(model)
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.swBackground)
                        .listRowSeparator(.hidden)
                }
                .onDelete { initiateDeletion(at: $0) }
            }
            .listStyle(.plain)
            .opacity(dialogs.isEmpty ? 0 : 1)
        }
        .animation(.default, value: dialogs.count)
        .background(
            NavigationLink(
                destination: lazyDestination,
                isActive: $selectedDialog.mappedToBool()
            )
        )
    }

    @ViewBuilder
    var lazyDestination: some View {
        if let selectedDialog {
            DialogScreen(dialog: selectedDialog) { markAsRead($0) }
        }
    }

    func dialogListItem(_ model: DialogResponse) -> some View {
        Button {
            selectedDialog = model
        } label: {
            DialogRowView(
                model: .init(
                    avatarURL: model.anotherUserImageURL,
                    authorName: model.anotherUserName ?? "",
                    dateText: model.lastMessageDateString,
                    messageText: model.lastMessageFormatted,
                    unreadCount: model.unreadMessagesCount
                )
            )
        }
    }

    var deleteDialogButton: some View {
        Button(role: .destructive) {
            deleteAction(at: indexToDelete)
        } label: {
            Text("Удалить")
        }
    }

    var hasFriends: Bool {
        defaults.hasFriends
    }

    func emptyViewAction() {
        openFriendList.toggle()
    }

    func markAsRead(_ dialog: DialogResponse) {
        dialogs = dialogs.map { item in
            if item.id == dialog.id {
                var updatedDialog = dialog
                updatedDialog.unreadMessagesCount = 0
                return updatedDialog
            } else {
                return item
            }
        }
        guard dialog.unreadMessagesCount > 0,
              defaults.unreadMessagesCount >= dialog.unreadMessagesCount
        else { return }
        let newValue = defaults.unreadMessagesCount - dialog.unreadMessagesCount
        defaults.saveUnreadMessagesCount(newValue)
    }

    func askForDialogs(refresh: Bool = false) async {
        if isLoading || (!dialogs.isEmpty && !refresh) { return }
        if !refresh { isLoading = true }
        do {
            dialogs = try await SWClient(with: defaults).getDialogs()
            let unreadMessagesCount = dialogs.map(\.unreadMessagesCount).reduce(0, +)
            defaults.saveUnreadMessagesCount(unreadMessagesCount)
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func initiateDeletion(at indexSet: IndexSet) {
        indexToDelete = indexSet.first
        showDeleteConfirmation.toggle()
    }

    func deleteAction(at index: Int?) {
        deleteDialogTask = Task {
            guard let index, !isLoading else { return }
            isLoading = true
            do {
                let dialogID = dialogs[index].id
                if try await SWClient(with: defaults).deleteDialog(dialogID) {
                    dialogs.remove(at: index)
                }
            } catch {
                setupErrorAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }
}

#if DEBUG
#Preview {
    DialogsListScreen()
        .environmentObject(DefaultsService())
}
#endif
