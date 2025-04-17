import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран для списка заблокированных пользователей
struct BlackListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var currentState = CurrentState.initial
    @State private var userToDelete: UserResponse?
    private var client: SWClient { SWClient(with: defaults) }

    var body: some View {
        ScrollView {
            contentView
                .animation(.default, value: currentState)
                .padding([.horizontal, .top])
                .frame(maxWidth: .infinity)
                .confirmationDialog(
                    .init(BlacklistOption.remove.dialogTitle),
                    isPresented: $userToDelete.mappedToBool(),
                    titleVisibility: .visible
                ) {
                    Button(
                        .init(BlacklistOption.remove.rawValue),
                        role: .destructive,
                        action: unblock
                    )
                } message: {
                    Text(.init(BlacklistOption.remove.dialogMessage))
                }
        }
        .onChange(of: currentState) { _ in
            if case let .ready(list) = currentState, list.isEmpty {
                dismiss()
            }
        }
        .loadingOverlay(if: currentState.isLoading)
        .background(Color.swBackground)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationTitle("Черный список")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension BlackListScreen {
    enum CurrentState: Equatable {
        case initial
        /// Загрузка с нуля или рефреш
        case loading
        /// Удаление пользователя из черного списка
        case unblockAction([UserResponse])
        case ready([UserResponse])
        case error(ErrorKind)

        var isLoading: Bool {
            switch self {
            case .loading, .unblockAction: true
            default: false
            }
        }

        /// Нужно ли загружать данные, когда их нет (или для рефреша)
        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(blockList): blockList.isEmpty
            case .loading, .unblockAction: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(blockList): !blockList.isEmpty
            default: false
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch currentState {
        case let .ready(blockedUsers), let .unblockAction(blockedUsers):
            LazyVStack(spacing: 12) {
                ForEach(blockedUsers) { user in
                    Button {
                        userToDelete = user
                    } label: {
                        makeLabelFor(user)
                    }
                    .opacity(userToDelete == user ? 0.5 : 1)
                    .scaleEffect(userToDelete == user ? 0.95 : 1)
                    .offset(x: userToDelete == user ? -32 : 0)
                    .animation(.easeInOut(duration: 0.2), value: userToDelete)
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

    func makeLabelFor(_ user: UserResponse) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: user.avatarURL,
                    name: user.userName ?? "",
                    address: SWAddress(user.countryID, user.cityID)?.address ?? ""
                )
            )
        )
    }

    func askForUsers(refresh: Bool = false) async {
        let needUpdateUser = defaults.needUpdateUser
        guard currentState.shouldLoad || needUpdateUser || refresh else { return }
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
            let users = try await client.getBlacklist()
            try? defaults.saveBlacklist(users)
            currentState = .ready(users)
        } catch {
            currentState = .error(.common(message: error.localizedDescription))
        }
    }

    func unblock() {
        guard let user = userToDelete else { return }
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        guard case let .ready(blockedUsers) = currentState else { return }
        currentState = .unblockAction(blockedUsers)
        Task {
            do {
                try await SWClient(with: defaults).blacklistAction(
                    user: user, option: .remove
                )
                defaults.updateBlacklist(option: .remove, user: user)
                defaults.setUserNeedUpdate(true)
                let updatedList = blockedUsers.filter { $0.id != user.id }
                currentState = .ready(updatedList)
            } catch {
                currentState = .ready(blockedUsers)
                SWAlert.shared.presentDefaultUIKit(error)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        BlackListScreen()
            .environmentObject(DefaultsService())
    }
    .navigationViewStyle(.stack)
}
#endif
