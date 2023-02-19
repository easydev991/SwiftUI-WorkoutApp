import SwiftUI
import SWModels

/// Список заявок на добавление в друзья
struct FriendRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @ObservedObject var viewModel: UsersListViewModel
    @State private var acceptRequestTask: Task<Void, Never>?
    @State private var declineRequestTask: Task<Void, Never>?

    var body: some View {
        List(viewModel.friendRequests, id: \.self) { item in
            FriendRequestCell(
                model: item,
                acceptClbk: accept,
                declineClbk: decline
            )
        }
        .disabled(viewModel.isLoading)
        .animation(.default, value: viewModel.friendRequests)
        .onChange(of: viewModel.friendRequests, perform: dismissIfNeeded)
        .onDisappear(perform: cancelTasks)
        .navigationTitle("Заявки")
        .navigationBarTitleDisplayMode(.inline)
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

    func dismissIfNeeded(items: [UserModel]) {
        if items.isEmpty { dismiss() }
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
