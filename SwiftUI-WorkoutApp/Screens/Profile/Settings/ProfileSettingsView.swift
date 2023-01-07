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
    let mode: Mode

    var body: some View {
        Form {
            if mode == .authorized {
                Section("Профиль") {
                    editAccountButton
                    changePasswordButton
                    logoutButton
                }
            }
            Section(mode.appInfoSectionTitle) {
                appVersionView
                feedbackButton
                rateAppButton
            }
        }
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .toolbar { deleteProfileButton }
        .onDisappear(perform: cancelTask)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ProfileSettingsView {
    enum Mode: CaseIterable {
        case authorized, incognito
    }
}

private extension ProfileSettingsView.Mode {
    var title: String {
        self == .authorized ? "Настройки" : "Информация"
    }

    var appInfoSectionTitle: String {
        self == .authorized ? "Информация о приложении" : ""
    }
}

private extension ProfileSettingsView {
    var editAccountButton: some View {
        NavigationLink(destination: AccountInfoView(mode: .edit)) {
            Text("Редактировать данные")
        }
    }

    var changePasswordButton: some View {
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
            Button("Выйти", role: .destructive) {
                defaults.triggerLogout()
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
        .opacity(mode == .authorized ? 1 : 0)
        .confirmationDialog(
            Constants.Alert.deleteProfile,
            isPresented: $showDeleteProfileDialog,
            titleVisibility: .visible
        ) {
            Button("Удалить учетную запись", role: .destructive, action: deleteProfile)
        }
    }

    func deleteProfile() {
        deleteProfileTask = Task { await viewModel.deleteProfile(with: defaults) }
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
        Button { viewModel.feedbackAction() } label: {
            Text("Отправить обратную связь")
        }
    }

    var rateAppButton: some View {
        Link("Оценить приложение", destination: Constants.appReviewURL)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTask() {
        deleteProfileTask?.cancel()
    }
}

#if DEBUG
struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ProfileSettingsView.Mode.allCases, id: \.self) { mode in
            NavigationView {
                ProfileSettingsView(mode: mode)
            }
            .previewDisplayName(mode == .authorized ? "Авторизованный" : "Инкогнито")
        }
        .environmentObject(DefaultsService())
    }
}
#endif
