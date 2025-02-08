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
    @State private var users = [UserResponse]()
    @State private var userToDelete: UserResponse?
    @State private var isLoading = false
    private var client: SWClient { SWClient(with: defaults) }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(users) { user in
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
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationTitle("Черный список")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension BlackListScreen {
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
        guard !isLoading else { return }
        do {
            if !users.isEmpty, !refresh { return }
            if !refresh { isLoading = true }
            users = try await client.getBlacklist()
            try? defaults.saveBlacklist(users)
            dismissIfEmpty()
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }

    func unblock() {
        guard let user = userToDelete else { return }
        isLoading = true
        Task {
            do {
                let isSuccess = try await SWClient(with: defaults).blacklistAction(
                    user: user, option: .remove
                )
                if isSuccess {
                    defaults.updateBlacklist(option: .remove, user: user)
                    users.removeAll(where: { $0.id == user.id })
                }
                dismissIfEmpty()
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func dismissIfEmpty() {
        if users.isEmpty { dismiss() }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        BlackListScreen()
            .environmentObject(DefaultsService())
    }
}
#endif
