//
//  UserProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var isFriendRequestSent = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var friendActionTask: Task<Void, Never>?
    let userID: Int

    var body: some View {
        ZStack {
            Form {
                userInfoSection
                if !viewModel.isMainUser {
                    communicationSection
                }
                socialInfoSection
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.user.isEmpty ? .zero : 1)
            .animation(.default, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .refreshable { await askForUserInfo(refresh: true) }
        .onChange(of: viewModel.requestedFriendship, perform: toggleFriendRequestSent)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if viewModel.isMainUser {
                    searchUsersLink
                    settingsLink
                }
            }
        }
        .onDisappear(perform: cancelFriendActionTask)
        .task(priority: .userInitiated) { await askForUserInfo() }
        .navigationTitle("Профиль")
    }
}

private extension UserProfileView {
    var userInfoSection: some View {
        Section {
            HStack(alignment: .center) {
                VStack(spacing: 16) {
                    avatarImageView
                    VStack(spacing: 4) {
                        Text(viewModel.user.name)
                            .fontWeight(.bold)
                        Text(viewModel.user.gender) + Text("yearsCount \(viewModel.user.age)", tableName: "Plurals")
                        Text(viewModel.user.shortAddress)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }

    var avatarImageView: some View {
        CacheAsyncImage(url: viewModel.user.imageURL) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            case .failure:
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 80)
            default:
                ProgressView()
            }
        }
    }

    var communicationSection: some View {
        Section {
            sendMessageLink
            friendActionButton
        }
    }

    var sendMessageLink: some View {
        NavigationLink {
#warning("TODO: сверстать экран для чата")
            Text("Экран для отправки сообщения")
                .navigationTitle(viewModel.user.name)
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text("Отправить сообщение")
                .fontWeight(.medium)
        }
    }

    var friendActionButton: some View {
        Button {
            friendActionTask = Task { await viewModel.friendAction(with: defaults) }
        } label: {
            Text(viewModel.friendActionOption.rawValue)
                .fontWeight(.medium)
        }
        .alert(Constants.Alert.friendRequestSent, isPresented: $isFriendRequestSent) {
            Button {} label: { TextOk() }
        }
    }

    func toggleFriendRequestSent(isSent: Bool) {
        isFriendRequestSent = isSent
    }

    var socialInfoSection: some View {
        Section {
            if viewModel.user.usesSportsGrounds > .zero {
                usesSportsGroundsLink
            }
            if !viewModel.user.addedSportsGrounds.isEmpty {
                addedSportsGroundsLink
            }
            if viewModel.user.friendsCount > .zero || friendRequestsCount > .zero {
                friendsLink
            }
            if viewModel.user.journalsCount > .zero {
                journalsLink
            }
        }
    }

    var usesSportsGroundsLink: some View {
        NavigationLink {
            SportsGroundListView(mode: .usedBy(userID: userID))
                .navigationTitle("Где тренируется")
        } label: {
            HStack {
                Label("Где тренируется", systemImage: "mappin.and.ellipse")
                Spacer()
                Text(viewModel.user.usesSportsGrounds.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var addedSportsGroundsLink: some View {
        NavigationLink {
            SportsGroundListView(mode: .added(list: viewModel.user.addedSportsGrounds))
                .navigationTitle("Добавленные")
        } label: {
            Label("Добавил площадки", systemImage: "mappin.and.ellipse")
            Spacer()
            Text(viewModel.user.addedSportsGrounds.count.description)
                .foregroundColor(.secondary)
        }
    }

    var friendsLink: some View {
        NavigationLink {
            UsersListView(mode: .friends(userID: viewModel.user.id))
                .navigationTitle("Друзья")
        } label: {
            HStack {
                Label("Друзья", systemImage: "person.3.sequence.fill")
                Spacer()
                if friendRequestsCount > .zero && viewModel.isMainUser {
                    Image(systemName: "\(friendRequestsCount).circle.fill")
                        .foregroundColor(.red)
                }
                Text(viewModel.user.friendsCount.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var journalsLink: some View {
        NavigationLink {
            Text("Экран с дневниками")
                .navigationTitle("Дневники")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Дневники", systemImage: "list.bullet")
                Spacer()
                Text(viewModel.user.journalsCount.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var searchUsersLink: some View {
        NavigationLink(destination: SearchUsersView()) {
            Image(systemName: "magnifyingglass")
        }
    }

    var settingsLink: some View {
        NavigationLink(destination: ProfileSettingsView()) {
            Image(systemName: "gearshape.fill")
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        await viewModel.makeUserInfo(for: userID, with: defaults, refresh: refresh)
        if viewModel.isMainUser {
            await viewModel.checkFriendRequests(with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    var friendRequestsCount: Int {
        defaults.friendRequestsList.count
    }

    func cancelFriendActionTask() {
        friendActionTask?.cancel()
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(userID: UserDefaultsService().mainUserID)
            .environmentObject(UserDefaultsService())
    }
}
