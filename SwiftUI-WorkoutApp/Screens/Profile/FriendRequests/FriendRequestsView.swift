import DesignSystem
import SwiftUI
import SWModels

/// Список заявок на добавление в друзья
struct FriendRequestsView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @ObservedObject var viewModel: UsersListViewModel
    @State private var acceptRequestTask: Task<Void, Never>?
    @State private var declineRequestTask: Task<Void, Never>?

    var body: some View {
        SectionView(headerWithPadding: "Заявки", mode: .card()) {
            LazyVStack(spacing: 0) {
                ForEach(Array(zip(viewModel.friendRequests.indices, viewModel.friendRequests)), id: \.0) { index, item in
                    UserRowView(
                        mode: .friendRequest(
                            .init(
                                imageURL: item.imageURL,
                                name: item.name,
                                address: item.shortAddress
                            ),
                            .init(
                                accept: { accept(userID: item.id) },
                                reject: { decline(userID: item.id) }
                            )
                        )
                    )
                    .withDivider(
                        if: index != viewModel.friendRequests.endIndex - 1
                    )
                }
            }
        }
        .animation(.default, value: viewModel.friendRequests)
        .onDisappear(perform: cancelTasks)
    }
}

private extension FriendRequestsView {
    func accept(userID: Int) {
        acceptRequestTask = Task {
            await viewModel.respondToFriendRequest(from: userID, accept: true, with: defaults)
        }
    }

    func decline(userID: Int) {
        declineRequestTask = Task {
            await viewModel.respondToFriendRequest(from: userID, accept: false, with: defaults)
        }
    }

    func cancelTasks() {
        [acceptRequestTask, declineRequestTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    FriendRequestsView(viewModel: .init())
        .environmentObject(DefaultsService())
}
#endif
