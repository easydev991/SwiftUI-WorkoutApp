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
    let userID: Int

    var body: some View {
        ZStack {
            Form {
                userInfoSection
                communicationSection
                socialInfoSection
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.user.isEmpty ? .zero : 1)
            .animation(.default, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: retryAction) {
                TextTryAgain()
            }
            Button(action: logout) {
                Text("Выйти")
            }
        }
        .refreshable { await askForUserInfo(refresh: true) }
        .onChange(of: viewModel.requestedFriendship) { isFriendRequestSent = $0 }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .toolbar { settingsLink }
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
            if !viewModel.isMainUser {
                sendMessageLink
                friendActionButton
            }
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
            Task { await viewModel.friendAction(with: defaults) }
        } label: {
            Text(viewModel.friendActionOption.rawValue)
                .fontWeight(.medium)
        }
        .alert(Constants.Alert.friendRequestSent, isPresented: $isFriendRequestSent) {
            Button(action: viewModel.friendRequestedAlertOKAction) {
                TextOk()
            }
        }
    }

    var socialInfoSection: some View {
        Section {
            if viewModel.user.usesSportsGrounds > .zero {
                usesSportsGroundsLink
            }
            if viewModel.user.addedSportsGrounds > .zero {
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
#warning("TODO: интеграция с сервером - GET ${API}/users/<user_id>/areas")
            Text("Площадки (где тренируется)")
                .navigationTitle("Где тренируется")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Где тренируется", systemImage: "mappin.and.ellipse")
                Spacer()
                Text("\(viewModel.user.usesSportsGrounds)")
                    .foregroundColor(.secondary)
            }
        }
    }

    var addedSportsGroundsLink: some View {
        NavigationLink {
            Text("Добавленные площадки")
                .navigationTitle("Добавленные")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Label("Добавил площадки", systemImage: "mappin.and.ellipse")
            Spacer()
            Text("\(viewModel.addedSportsGrounds)")
                .foregroundColor(.secondary)
        }
    }

    var friendsLink: some View {
        NavigationLink {
            UsersListView(mode: .friends(userID: viewModel.user.id))
                .navigationTitle("Друзья")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Друзья", systemImage: "person.3.sequence.fill")
                Spacer()
                if friendRequestsCount > .zero && viewModel.isMainUser {
                    Image(systemName: "\(friendRequestsCount).circle.fill")
                        .foregroundColor(.red)
                }
                Text("\(viewModel.user.friendsCount)")
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
                Text("\(viewModel.user.journalsCount)")
                    .foregroundColor(.secondary)
            }
        }
    }

    var settingsLink: some View {
        NavigationLink(destination: ProfileSettingsView()) {
            Image(systemName: "gearshape.fill")
        }
        .opacity(viewModel.isMainUser ? 1 : .zero)
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

    func logout() { defaults.triggerLogout() }

    func retryAction() {
        Task { await askForUserInfo() }
    }

    var friendRequestsCount: Int {
        defaults.friendRequestsList.count
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(userID: UserDefaultsService().mainUserID)
            .environmentObject(UserDefaultsService())
    }
}
