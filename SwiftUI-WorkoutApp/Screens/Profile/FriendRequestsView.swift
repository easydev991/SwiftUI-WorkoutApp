//
//  FriendRequestsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 08.05.2022.
//

import SwiftUI

struct FriendRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: UserDefaultsService
    @ObservedObject var viewModel: UsersListViewModel
    @State private var acceptRequestTask: Task<Void, Never>?
    @State private var declineRequestTask: Task<Void, Never>?

    var body: some View {
        List(viewModel.friendRequests, id: \.self) { item in
            FriendRequestRow(model: item, acceptClbk: accept, declineClbk: decline)
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
            await viewModel.respondToFriendRequest(from: userID, with: defaults, accept: true)
        }
    }

    func decline(userID: Int) {
        declineRequestTask = Task {
            await viewModel.respondToFriendRequest(from: userID, with: defaults, accept: false)
        }
    }

    func dismissIfNeeded(items: [UserModel]) {
        if items.isEmpty { dismiss() }
    }

    func cancelTasks() {
        [acceptRequestTask, declineRequestTask].forEach { $0?.cancel() }
    }
}

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView(viewModel: .init())
    }
}
