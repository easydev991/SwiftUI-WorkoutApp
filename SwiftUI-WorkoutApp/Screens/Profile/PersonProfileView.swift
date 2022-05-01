//
//  PersonProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct PersonProfileView: View {
    @StateObject private var viewModel = PersonProfileViewModel()
    let user: TempPersonModel
    @State private var isFriendRequestSent = false

    var body: some View {
        Form {
            personInfoSection()
            if !user.isMainUser {
                communicationSection()
            }
            socialInfoSection()
        }
        .onChange(of: viewModel.requestedFriendship) { isSuccess in
            isFriendRequestSent = isSuccess
        }
        .toolbar {
            if user.isMainUser {
                settingsLink()
            }
        }
    }
}

private extension PersonProfileView {
    func personInfoSection() -> some View {
        Section {
            HStack(spacing: 24) {
                avatarImageView()
                VStack {
                    Text(user.name)
                        .fontWeight(.bold)
                    Text(user.genderAge)
                    Text(user.shortAddress)
                }
            }
        }
    }

    func avatarImageView() -> some View {
        AsyncImage(url: .init(string: user.imageStringURL)) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 120)
                    .cornerRadius(8)
            case .failure:
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.leading)
            default:
                ProgressView()
            }
        }
    }

    func communicationSection() -> some View {
        Section {
            sendMessageLink()
            if viewModel.isAddFriendButtonEnabled {
                addNewFriendButton()
            }
        }
    }

    func sendMessageLink() -> some View {
        NavigationLink {
#warning("TODO: сверстать экран для чата")
            Text("Экран для отправки сообщения")
                .navigationTitle(user.name)
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text("Отправить сообщение")
                .fontWeight(.medium)
        }

    }

    func addNewFriendButton() -> some View {
        Button {
            viewModel.sendFriendRequest()
        } label: {
            Text("Предложить дружбу")
                .fontWeight(.medium)
        }
        .alert(Constants.AlertTitle.friendRequestSent, isPresented: $isFriendRequestSent) {
            okButton()
        }
    }

    func okButton() -> some View {
        Button {
            viewModel.friendRequestedAlertOKAction()
        } label: {
            Text("Ок")
        }
    }

    func socialInfoSection() -> some View {
        Section {
            if user.usesSportsGrounds > 0 {
                usesSportsGroundsLink()
            }
            if user.addedSportsGrounds > 0 {
                addedSportsGroundsLink()
            }
            if user.friendsCount > 0 {
                friendsLink()
            }
            if user.journalsCount > 0 {
                journalsLink()
            }
        }
    }

    func usesSportsGroundsLink() -> some View {
        NavigationLink {
            Text("Площадки (где тренируется)")
                .navigationTitle("Где тренируется")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Где тренируется", systemImage: "mappin.and.ellipse")
                Spacer()
                Text("\(user.usesSportsGrounds)")
                    .foregroundColor(.secondary)
            }
        }
    }

    func addedSportsGroundsLink() -> some View {
        NavigationLink {
            Text("Добавленные площадки")
                .navigationTitle("Добавленные")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Label("Добавил площадки", systemImage: "mappin.and.ellipse")
            Spacer()
            Text("\(user.addedSportsGrounds)")
                .foregroundColor(.secondary)
        }
    }

    func friendsLink() -> some View {
        NavigationLink {
            PersonsListView(model: .mock)
                .navigationTitle("Друзья")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Друзья", systemImage: "person.3.sequence.fill")
                Spacer()
                Text("\(user.friendsCount)")
                    .foregroundColor(.secondary)
            }
        }
    }

    func journalsLink() -> some View {
        NavigationLink {
            Text("Экран с дневниками")
                .navigationTitle("Дневники")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Дневники", systemImage: "list.bullet")
                Spacer()
                Text("\(user.journalsCount)")
                    .foregroundColor(.secondary)
            }
        }
    }

    func settingsLink() -> some View {
        NavigationLink {
            ProfileSettingsView()
        } label: {
            Image(systemName: "gearshape.fill")
        }
    }
}

struct PersonProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PersonProfileView(user: .mockMain)
    }
}
