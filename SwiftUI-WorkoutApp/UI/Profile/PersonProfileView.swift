//
//  PersonProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct PersonProfileView: View {
    @State private var alertTitle = "Запрос отправлен!"
    @State private var isFriendRequestSent = false
#warning("TODO: вынести это свойство во viewModel")
    @State private var isAddFriendButtonEnabled = true

    let model: TempPersonModel

    var body: some View {
        Form {
            personInfoSection()
            if !model.isMainUser {
                communicationSection()
            }
            socialInfoSection()
        }
        .toolbar {
            if model.isMainUser {
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
                    Text(model.name)
                        .fontWeight(.bold)
                    Text(model.genderAge)
                    Text(model.shortAddress)
                }
            }
        }
    }

    func avatarImageView() -> some View {
        AsyncImage(url: .init(string: model.imageStringURL)) { phase in
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
            if isAddFriendButtonEnabled {
                addNewFriendButton()
            }
        }
    }

    func sendMessageLink() -> some View {
        NavigationLink {
#warning("TODO: сверстать экран для чата")
            Text("Экран для отправки сообщения")
                .navigationTitle(model.name)
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text("Отправить сообщение")
                .fontWeight(.medium)
        }

    }

    func addNewFriendButton() -> some View {
        Button {
#warning("TODO: интеграция с сервером")
            print("Отправляем запрос на добавление в друзья")
            isFriendRequestSent.toggle()
        } label: {
            Text("Предложить дружбу")
                .fontWeight(.medium)
        }
        .alert(alertTitle, isPresented: $isFriendRequestSent) {
            okButton()
        }
    }

    func okButton() -> some View {
        Button {
            isAddFriendButtonEnabled.toggle()
        } label: {
            Text("Ок")
        }
    }

    func socialInfoSection() -> some View {
        Section {
            if model.usesSportsGrounds > 0 {
                usesSportsGroundsLink()
            }
            if model.addedSportsGrounds > 0 {
                addedSportsGroundsLink()
            }
            if model.friendsCount > 0 {
                friendsLink()
            }
            if model.journalsCount > 0 {
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
                Text("\(model.usesSportsGrounds)")
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
            Text("\(model.addedSportsGrounds)")
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
                Text("\(model.friendsCount)")
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
                Text("\(model.journalsCount)")
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
        PersonProfileView(model: .mockMain)
            .previewDevice("iPhone 13 mini")
    }
}
