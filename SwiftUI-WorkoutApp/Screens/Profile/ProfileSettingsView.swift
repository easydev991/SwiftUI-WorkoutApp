//
//  ProfileSettingsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.04.2022.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @State private var showLogoutConfirmation = false

    var body: some View {
        Form {
            Section("Профиль") {
                editAccountLink
                changePasswordLink
                logoutButton
            }
            Section("Информация о приложении") {
                appVersionView
                feedbackButton
                rateAppButton
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileSettingsView {
    var editAccountLink: some View {
        NavigationLink(destination: EditAccountView()) {
            Text("Редактировать данные")
        }
    }

    var changePasswordLink: some View {
        NavigationLink(destination: ChangePasswordView()) {
            Text("Изменить пароль")
        }
    }

    var logoutButton: some View {
        Button(action: showConfirmatinoDialog) {
            Text("Выйти")
                .foregroundColor(.pink)
        }
        .confirmationDialog(
            Constants.Alert.logout,
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive, action: defaults.triggerLogout) {
                Text("Выйти")
            }
        }
    }

    func showConfirmatinoDialog() {
        showLogoutConfirmation.toggle()
    }

    var appVersionView: some View {
        HStack {
            Text("Версия")
            Spacer()
            Text(Constants.appVersion)
                .foregroundColor(.secondary)
        }
    }

    var feedbackButton: some View {
        Button(action: viewModel.feedbackAction) {
            Text("Отправить обратную связь")
        }
    }

    var rateAppButton: some View {
        Button(action: viewModel.rateAppAction) {
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
