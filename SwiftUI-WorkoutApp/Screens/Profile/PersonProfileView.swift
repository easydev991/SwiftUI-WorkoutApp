//
//  PersonProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct PersonProfileView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @ObservedObject var viewModel: PersonProfileViewModel
    @State private var isFriendRequestSent = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""

    var body: some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
            Form {
                personInfoSection
                if viewModel.showCommunication {
                    communicationSection
                }
                socialInfoSection
            }
            .opacity(viewModel.isLoading ? .zero : 1)
            .animation(.easeIn, value: viewModel.user.id)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: retryAction) {
                TextTryAgain()
            }
        }
        .onChange(of: viewModel.requestedFriendship) { isFriendRequestSent = $0 }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .toolbar { settingsLink }
        .task { await askForUserInfo() }
        .navigationTitle("Профиль")
    }
}

private extension PersonProfileView {
    var personInfoSection: some View {
        Section {
            HStack(alignment: .center) {
                VStack(spacing: 16) {
                    avatarImageView
                    VStack(spacing: 4) {
                        Text(viewModel.user.name)
                            .fontWeight(.bold)
                        Text("\(viewModel.user.gender), ") + Text(
                            "yearsCount \(viewModel.user.age)",
                            tableName: "Plurals"
                        )
                        Text(viewModel.userShortAddress)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }

    var avatarImageView: some View {
        AsyncImage(url: viewModel.user.imageURL) { phase in
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
            if viewModel.isAddFriendButtonEnabled {
                addNewFriendButton
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

    var addNewFriendButton: some View {
        Button(action: viewModel.sendFriendRequest) {
            Text("Предложить дружбу")
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
            if viewModel.user.friendsCount > .zero {
                friendsLink
            }
            if viewModel.user.journalsCount > .zero {
                journalsLink
            }
        }
    }

    var usesSportsGroundsLink: some View {
        NavigationLink {
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
            PersonsListView(viewModel: .init(mode: .friends(userID: viewModel.user.id)))
                .navigationTitle("Друзья")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Друзья", systemImage: "person.3.sequence.fill")
                Spacer()
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
        .opacity(viewModel.showSettingsButton ? 1 : .zero)
    }

    func askForUserInfo() async {
        await viewModel.makeUserInfo(with: defaults)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func retryAction() {
        Task {
            await askForUserInfo()
        }
    }
}

struct PersonProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PersonProfileView(viewModel: .init(userID: 1))
    }
}
