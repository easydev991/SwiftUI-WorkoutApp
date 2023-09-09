import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Список диалогов
struct DialogListView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogListViewModel()
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
            .loadingOverlay(if: viewModel.isLoading)
            .background(Color.swBackground)
            .confirmationDialog(
                Constants.Alert.deleteDialog,
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) { deleteDialogButton }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .alert(errorTitle, isPresented: $showErrorAlert) {
                Button("Ok", action: closeAlert)
            }
            .task { await askForDialogs() }
            .refreshable { await askForDialogs(refresh: true) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    friendListButton
                }
            }
            .onDisappear(perform: cancelTasks)
    }
}

private extension DialogListView {
    var refreshButton: some View {
        Button {
            refreshTask = Task {
                await askForDialogs(refresh: true)
            }
        } label: {
            Image(systemName: Icons.Regular.refresh.rawValue)
        }
        .opacity(showEmptyView || !DeviceOSVersionChecker.iOS16Available ? 1 : 0)
        .disabled(viewModel.isLoading)
    }

    var friendListButton: some View {
        NavigationLink(isActive: $openFriendList) {
            if hasFriends, let mainUserID = defaults.mainUserInfo?.userID {
                UsersListView(mode: .friendsForChat(userID: mainUserID))
            } else {
                SearchUsersView(mode: .chat)
            }
        } label: {
            Image(systemName: Icons.Regular.plus.rawValue)
        }
        .opacity(hasFriends || !viewModel.list.isEmpty ? 1 : 0)
        .disabled(!network.isConnected)
    }

    var emptyContentView: some View {
        EmptyContentView(
            mode: .dialogs,
            isAuthorized: defaults.isAuthorized,
            hasFriends: defaults.hasFriends,
            hasSportsGrounds: defaults.hasSportsGrounds,
            isNetworkConnected: network.isConnected,
            action: emptyViewAction
        )
        .opacity(showEmptyView ? 1 : 0)
        .disabled(viewModel.isLoading)
    }

    var showEmptyView: Bool {
        viewModel.list.isEmpty
    }

    var emptyViewButtonTitle: String {
        hasFriends
            ? "Открыть список друзей"
            : "Найти пользователя"
    }

    var dialogList: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                ForEach(viewModel.list) { model in
                    NavigationLink {
                        DialogView(
                            dialog: model,
                            markedAsReadClbk: {
                                viewModel.markAsRead(model, with: defaults)
                            }
                        )
                    } label: {
                        DialogRowView(
                            model: .init(
                                avatarURL: model.anotherUserImageURL,
                                authorName: model.anotherUserName.valueOrEmpty,
                                dateText: model.lastMessageDateString,
                                messageText: model.lastMessageFormatted,
                                unreadCount: model.unreadMessagesCount
                            )
                        )
                    }
                }
                .onDelete(perform: initiateDeletion)
            }
            .padding([.top, .horizontal])
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

    func askForDialogs(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
    }

    func initiateDeletion(at indexSet: IndexSet) {
        indexToDelete = indexSet.first
        showDeleteConfirmation.toggle()
    }

    func deleteAction(at index: Int?) {
        deleteDialogTask = Task {
            await viewModel.deleteDialog(at: index, with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [refreshTask, deleteDialogTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct DialogListView_Previews: PreviewProvider {
    static var previews: some View {
        DialogListView()
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif
