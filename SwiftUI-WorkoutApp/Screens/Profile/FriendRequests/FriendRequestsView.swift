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
        VStack(spacing: 0) {
            SectionHeaderView("Заявки")
            LazyVStack(spacing: 0) {
                ForEach(itemsTuple, id: \.0) { index, item in
                    VStack(spacing: 12) {
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
                        dividerIfNeeded(at: index)
                    }
                }
            }
            .insideCardBackground(padding: 0)
        }
        .animation(.default, value: viewModel.friendRequests)
        .onDisappear(perform: cancelTasks)
    }
}

private extension FriendRequestsView {
    var itemsTuple: [(Int, UserModel)] {
        .init(zip(viewModel.friendRequests.indices, viewModel.friendRequests))
    }

    #warning("Вынести в дизайн-систему")
    @ViewBuilder
    func dividerIfNeeded(at index: Int) -> some View {
        if index != itemsTuple.endIndex - 1 {
            Divider()
                .background(Color.swSeparators)
        }
    }

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
struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView(viewModel: .init())
            .environmentObject(DefaultsService())
    }
}
#endif
