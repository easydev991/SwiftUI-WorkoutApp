//
//  ProfileSettingsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.04.2022.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @State private var showLogoutConfirmation = false

    var body: some View {
        Form {
            Section("Профиль") {
                editAccountLink()
                changePasswordLink()
                logoutButton()
            }
            Section("Информация о приложении") {
                appVersionView()
                feedbackButton()
                rateAppButton()
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileSettingsView {
    func editAccountLink() -> some View {
        NavigationLink {
            EditAccountView()
        } label: {
            Text("Редактировать данные")
        }
    }

    func changePasswordLink() -> some View {
        NavigationLink {
            ChangePasswordView()
        } label: {
            Text("Изменить пароль")
        }
    }

    func logoutButton() -> some View {
        Button {
            showLogoutConfirmation = true
        } label: {
            Text("Выйти")
                .foregroundColor(.pink)
        }
        .confirmationDialog(
            Constants.AlertTitle.logout,
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                userDefaults.setUserLoggedOut()
            } label: {
                Text("Выйти")
            }
        }
    }

    func appVersionView() -> some View {
        HStack {
            Text("Версия")
            Spacer()
            Text(Constants.appVersion)
                .foregroundColor(.secondary)
        }
    }

    func feedbackButton() -> some View {
        Button {
            viewModel.feedbackAction()
        } label: {
            Text("Отправить обратную связь")
        }
    }

    func rateAppButton() -> some View {
        Button {
            viewModel.rateAppAction()
        } label: {
            Text("Оценить приложение")
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
            .environmentObject(UserDefaultsService())
    }
}
