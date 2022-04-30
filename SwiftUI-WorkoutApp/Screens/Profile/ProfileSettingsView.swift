//
//  ProfileSettingsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.04.2022.
//

import SwiftUI
import StoreKit

struct ProfileSettingsView: View {
    @EnvironmentObject var appState: AppState

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
#warning("TODO: выход из учетной записи")
            appState.setIsUserAuth(false)
        } label: {
            Text("Выйти")
                .foregroundColor(.pink)
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
            appState.sendFeedback()
        } label: {
            Text("Отправить обратную связь")
        }
    }

    func rateAppButton() -> some View {
        Button {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        } label: {
            Text("Оценить приложение")
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
            .environmentObject(AppState())
    }
}
