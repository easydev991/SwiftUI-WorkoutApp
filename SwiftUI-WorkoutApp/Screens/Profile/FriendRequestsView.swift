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

    var body: some View {
        List(viewModel.friendRequests, id: \.self) { item in
            FriendRequestRow(model: item, acceptClbk: accept, declineClbk: decline)
        }
        .animation(.default, value: viewModel.friendRequests)
        .onChange(of: viewModel.friendRequests, perform: dismissIfNeeded)
        .navigationTitle("Заявки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension FriendRequestsView {
    func accept(userID: Int) {
#warning("TODO: интеграция с сервером")
        print("приняли заявку")
        Task {
            await viewModel.acceptFriendRequest(from: userID, with: defaults)
        }
    }

    func decline(userID: Int) {
#warning("TODO: интеграция с сервером")
        print("отклонили заявку")
    }

    func dismissIfNeeded(items: [UserModel]) {
        if items.isEmpty { dismiss() }
    }
}

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView(viewModel: .init())
    }
}
