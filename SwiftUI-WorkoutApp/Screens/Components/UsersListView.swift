//
//  UsersListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = UsersListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    let mode: Mode

    var body: some View {
        ZStack {
            Form {
                if !viewModel.friendRequests.isEmpty {
                    friendRequestsSection
                }
                List(viewModel.users, id: \.self) { user in
                    NavigationLink {
                        UserProfileView(userID: user.id)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        UserViewCell(model: user)
                    }
                    .disabled(isLinkDisabled(for: user.id))
                }
            }
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension UsersListView {
    enum Mode {
        case friends(userID: Int)
        case sportsGroundVisitors(list: [UserResponse])
    }
}

private extension UsersListView {
    var friendRequestsSection: some View {
        Section {
            NavigationLink {
                FriendRequestsView(viewModel: viewModel)
            } label: {
                HStack {
                    Label("Заявки", systemImage: "person.fill.badge.plus")
                    Spacer()
                    Text(viewModel.friendRequests.count.description)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    func isLinkDisabled(for userID: Int) -> Bool {
        userID == defaults.mainUserID || !defaults.isAuthorized
    }

    func askForUsers(refresh: Bool = false) async {
        await viewModel.makeInfo(for: mode, with: defaults, refresh: refresh)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView(mode: .friends(userID: DefaultsService().mainUserID))
            .environmentObject(DefaultsService())
    }
}
