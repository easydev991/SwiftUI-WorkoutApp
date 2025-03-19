import SWDesignSystem
import SwiftUI
import SWModels
import SWUtils

/// Экран со списком диалогов
struct DialogsListScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var viewModel: DialogsViewModel
    @State private var selectedDialog: DialogResponse?
    @State private var indexToDelete: Int?
    @State private var openFriendList = false
    @State private var refreshTask: Task<Void, Never>?
    @State private var deleteDialogTask: Task<Void, Never>?

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
        .onChange(of: scenePhase) { phase in
            if case .active = phase {
                refreshTask = Task {
                    try? await viewModel.getDialogs(refresh: true, defaults: defaults)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

private extension DialogsListScreen {
    var authorizedContentView: some View {
        stateContentView
            .animation(.default, value: viewModel.currentState)
            .loadingOverlay(if: viewModel.currentState.isLoading)
            .background(Color.swBackground)
            .background(
                NavigationLink(
                    destination: lazyDestination,
                    isActive: $selectedDialog.mappedToBool()
                )
            )
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
            ContainerRelativeView {
                Text("Загрузка...")
            }
        }
    }

    var refreshButton: some View {
        Button {
            refreshTask = Task { await askForDialogs() }
        } label: {
            Icons.Regular.refresh.view
        }
        .opacity(viewModel.currentState.isReadyAndEmpty ? 1 : 0)
        .disabled(viewModel.currentState.isLoading)
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
        .opacity(hasFriends || viewModel.currentState.isReadyAndNotEmpty ? 1 : 0)
    }

    var emptyContentView: some View {
        EmptyContentView(
            mode: .dialogs,
            action: { openFriendList.toggle() }
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
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        do {
            try await viewModel.getDialogs(refresh: refresh, defaults: defaults)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
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
        .environmentObject(DefaultsService())
        .environmentObject(DialogsViewModel())
}
#endif
