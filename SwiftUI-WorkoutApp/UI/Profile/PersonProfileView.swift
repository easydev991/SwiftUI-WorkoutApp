//
//  PersonProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct PersonProfileView: View {
    @EnvironmentObject var appState: AppState
    let model: TempPersonModel

    var body: some View {
        Form {
            personInfoSection()
            socialInfoSection()
        }
        .toolbar {
            if model.isMainUser {
                settingsButton()
            }
        }
    }
}

private extension PersonProfileView {
    func personInfoSection() -> some View {
        Section {
            HStack(spacing: 24) {
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
                VStack {
                    Text(model.name)
                        .fontWeight(.bold)
                    Text(model.genderAge)
                    Text(model.shortAddress)
                }
            }
#warning("TODO: добавить кнопки для чата и добавления в друзья")
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
        } label: {
            HStack {
                Label("Дневники", systemImage: "list.bullet")
                Spacer()
                Text("\(model.journalsCount)")
                    .foregroundColor(.secondary)
            }
        }
    }

    func settingsButton() -> some View {
        NavigationLink {
            ProfileSettingsView()
        } label: {
            Image(systemName: "gearshape.fill")
        }
    }
}

struct PersonProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PersonProfileView(model: .mockSingle)
            .previewDevice("iPhone 13 mini")
        .environmentObject(AppState())
    }
}
