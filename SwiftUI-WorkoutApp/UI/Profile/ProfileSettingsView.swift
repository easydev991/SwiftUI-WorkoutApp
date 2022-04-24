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
                editAccountView()
                changePasswordView()
                Button {
#warning("TODO: выход из учетной записи")
                    appState.isUserAuthorized = false
                } label: {
                    Text("Выйти")
                        .foregroundColor(.pink)
                }
            }
            Section("Информация о приложении") {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text(Constants.appVersion)
                        .foregroundColor(.secondary)
                }
                Button {
                    appState.sendFeedback()
                } label: {
                    Text("Отправить обратную связь")
                }
                Button {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                } label: {
                    Text("Оценить приложение")
                }
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileSettingsView {
    func editAccountView() -> some View {
        NavigationLink {
#warning("TODO: открыть экран для редактирования данных существующего пользователя")
            EditAccountView()
        } label: {
            Text("Редактировать данные")
        }
    }

    func changePasswordView() -> some View {
        NavigationLink {
            ChangePasswordView()
        } label: {
            Text("Изменить пароль")
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
            .environmentObject(AppState())
    }
}
