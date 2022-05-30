import SwiftUI

/// Экран с настройками профиля основного пользователя
struct ProfileSettingsView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @State private var showLogoutDialog = false
    @State private var showDeleteProfileDialog = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var deleteProfileTask: Task<Void, Never>?

    var body: some View {
        ZStack {
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
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .toolbar { deleteProfileButton }
        .onDisappear(perform: cancelTask)
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProfileSettingsView {
    var editAccountLink: some View {
        NavigationLink {
            AccountInfoView()
                .navigationTitle("Изменить профиль")
        } label: {
            Text("Редактировать данные")
        }
    }

    var changePasswordLink: some View {
        NavigationLink(destination: ChangePasswordView()) {
            Text("Изменить пароль")
        }
    }

    var logoutButton: some View {
        Button {
            showLogoutDialog.toggle()
        } label: {
            Text("Выйти")
                .foregroundColor(.pink)
        }
        .confirmationDialog(
            Constants.Alert.logout,
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                defaults.triggerLogout()
            } label: {
                Text("Выйти")
            }
        }
    }

    var deleteProfileButton: some View {
        Button {
            showDeleteProfileDialog.toggle()
        } label: {
            Image(systemName: "trash")
                .tint(.secondary)
        }
        .confirmationDialog(
            Constants.Alert.deleteProfile,
            isPresented: $showDeleteProfileDialog,
            titleVisibility: .visible
        ) {
            Button(role: .destructive, action: deleteProfile) {
                Text("Удалить учетную запись")
            }
        }
    }

    func deleteProfile() {
        deleteProfileTask = Task { await viewModel.deleteProfile() }
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

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() { viewModel.clearErrorMessage() }

    func cancelTask() { deleteProfileTask?.cancel() }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
            .environmentObject(DefaultsService())
    }
}
