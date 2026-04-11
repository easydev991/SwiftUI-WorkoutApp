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
    @EnvironmentObject private var viewModel: ViewModel
    @State private var indexToDelete: Int?
    @State private var openFriendList = false
    @State private var refreshTask: Task<Void, Never>?
    @State private var deleteDialogTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
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
        .trackScreen(.dialogsList)
    }
}

private extension DialogsListScreen {
    var authorizedContentView: some View {
        stateContentView
            .animation(.default, value: viewModel.currentState)
            .loadingOverlay(if: viewModel.currentState.isLoading)
            .background(Color.swBackground)
            .confirmationDialog(
                Strings.Alert.deleteDialog,
                isPresented: $indexToDelete.mappedToBool(),
                titleVisibility: .visible
            ) { deleteDialogButton }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentState.isReadyAndEmpty {
                        refreshButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    friendListButton
                }
            }
            .navigationDestination(for: DialogResponse.self) { dialog in
                DialogScreen(
                    dialog: dialog,
                    markedAsReadClbk: { dialog in
                        viewModel.markAsRead(dialog, defaults: defaults)
                    }
                )
            }
            .navigationDestination(isPresented: $openFriendList) {
                if hasFriends, let mainUserId = defaults.mainUserInfo?.id {
                    FriendsListScreen(mode: .chat(userId: mainUserId))
                } else {
                    SearchUsersScreen(mode: .chat)
                }
            }
    }

    @ViewBuilder
    var stateContentView: some View {
        switch viewModel.currentState {
        case let .ready(dialogs), let .deleteDialog(dialogs):
            ZStack {
                Color.swBackground
                if dialogs.isEmpty {
                    emptyContentView
                } else {
                    List {
                        ForEach(dialogs) { model in
                            dialogListItem(model)
                                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .listRowBackground(Color.swBackground)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete { indexToDelete = $0.first }
                    }
                    .listStyle(.plain)
                    .refreshable { await askForDialogs(refresh: true) }
                }
            }
            .animation(.default, value: dialogs.isEmpty)
        case let .error(errorKind):
            CommonErrorView(errorKind: errorKind)
        case .initial, .loading:
            Color.swBackground
        }
    }

    var refreshButton: some View {
        Button {
            refreshTask = Task { await askForDialogs() }
        } label: {
            Icons.Regular.refresh.view
        }
        .tint(.accent)
        .disabled(viewModel.currentState.isLoading)
    }

    @ViewBuilder
    var friendListButton: some View {
        if hasFriends || viewModel.currentState.isReadyAndNotEmpty {
            Button {
                openFriendList.toggle()
            } label: {
                Icons.Regular.plus.view.symbolVariant(.circle)
            }
            .tint(.accent)
        }
    }

    var emptyContentView: some View {
        EmptyContentView(
            mode: .dialogs,
            action: { openFriendList.toggle() }
        )
    }

    func dialogListItem(_ model: DialogResponse) -> some View {
        NavigationLink(value: model) {
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
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        await viewModel.getDialogs(refresh: refresh, defaults: defaults)
    }

    func deleteAction(at index: Int?) {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
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
        .environmentObject(DialogsListScreen.ViewModel(isUITest: true, authHelper: MockAuthHelper()))
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
}
#endif
