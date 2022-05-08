//
//  FriendRequestsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 08.05.2022.
//

import SwiftUI

struct FriendRequestsView: View {
    @ObservedObject var viewModel: UsersListViewModel

    var body: some View {
        List(viewModel.friendRequests, id: \.self) { item in
            FriendRequestRow(model: item, acceptClbk: accept, declineClbk: decline)
        }
        .navigationTitle("Заявки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension FriendRequestsView {
    func accept() {
#warning("TODO: интеграция с сервером")
        print("приняли заявку")
    }

    func decline() {
#warning("TODO: интеграция с сервером")
        print("отклонили заявку")
    }
}

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView(viewModel: .init())
    }
}
