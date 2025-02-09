import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком диалогов
struct DialogsListScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogsViewModel()
    @State private var selectedDialog: DialogResponse?
    @State private var indexToDelete: Int?
    @State private var openFriendList = false
    @State private var refreshTask: Task<Void, Never>?
    @State private var deleteDialogTask: Task<Void, Never>?
    private var client: SWClient { SWClient(with: defaults) }

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    authorizedContentView
                        .navigationBarTitleDisplayMode(.inline)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    IncognitoProfileView()
                }
            }
            .animation(.spring, value: defaults.isAuthorized)
            .background(Color.swBackground)
            .navigationTitle("Сообщения")
        }
        .navigationViewStyle(.stack)
        .onChange(of: defaults.isAuthorized, perform: viewModel.clearDialogsOnLogout)
        .onChange(of: scenePhase) { phase in
            if case .active = phase {
                guard refreshTask == nil else { return }
                refreshTask = Task { await askForDialogs(refresh: true) }
            }
        }
        .task(id: defaults.isAuthorized) { await askForDialogs() }
    }
}

private extension DialogsListScreen {
    var authorizedContentView: some View {
        dialogList
            .overlay { emptyContentView }
            .loadingOverlay(if: viewModel.isLoading)
            .background(Color.swBackground)
            .confirmationDialog(
                .init(Constants.Alert.deleteDialog),
                isPresented: $indexToDelete.mappedToBool(),
                titleVisibility: .visible
            ) { deleteDialogButton }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    refreshButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    friendListButton
                }
            }
    }

    var refreshButton: some View {
        Button {
            refreshTask = Task {
                await askForDialogs(refresh: true)
            }
        } label: {
            Icons.Regular.refresh.view
        }
        .opacity(viewModel.showEmptyView ? 1 : 0)
        .disabled(viewModel.isLoading || !isNetworkConnected)
    }

    var friendListButton: some View {
        NavigationLink(isActive: $openFriendList) {
            if hasFriends, let mainUserID = defaults.mainUserInfo?.id {
                FriendsListScreen(mode: .chat(userID: mainUserID))
            } else {
                SearchUsersScreen(mode: .chat)
            }
        } label: {
            Icons.Regular.plus.view
                .symbolVariant(.circle)
        }
        .opacity(hasFriends || viewModel.hasDialogs ? 1 : 0)
        .disabled(!isNetworkConnected)
    }

    var emptyContentView: some View {
        EmptyContentView(
            mode: .dialogs,
            action: { openFriendList.toggle() }
        )
        .opacity(viewModel.showEmptyView ? 1 : 0)
    }

    @ViewBuilder
    var dialogList: some View {
        ZStack {
            Color.swBackground
            List {
                ForEach(viewModel.dialogs) { model in
                    dialogListItem(model)
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.swBackground)
                        .listRowSeparator(.hidden)
                }
                .onDelete { indexToDelete = $0.first }
            }
            .listStyle(.plain)
            .opacity(viewModel.hasDialogs ? 1 : 0)
            .refreshable { await askForDialogs(refresh: true) }
        }
        .animation(.default, value: viewModel.dialogs.count)
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
            DialogScreen(
                dialog: selectedDialog,
                markedAsReadClbk: { dialog in
                    viewModel.markAsRead(dialog, defaults: defaults)
                }
            )
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

    func askForDialogs(refresh: Bool = false) async {
        do {
            try await viewModel.askForDialogs(refresh: refresh, defaults: defaults)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func deleteAction(at index: Int?) {
        deleteDialogTask = Task {
            do {
                try await viewModel.deleteDialog(at: index, defaults: defaults)
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
        }
    }
}

#if DEBUG
#Preview {
    DialogsListScreen()
        .environmentObject(DefaultsService())
}
#endif
