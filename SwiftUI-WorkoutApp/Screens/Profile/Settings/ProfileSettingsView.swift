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
            Section {
                if mode == .authorized {
                    editAccountButton
                    changePasswordButton
                    logoutButton
                } else {
                    registerButton
                    authorizeButton
                }
            } header: {
                Text("Профиль")
            } footer: {
                mode.profileSectionFooter
            }
            Section(mode.appInfoSectionTitle) {
                feedbackButton
                rateAppButton
                userAgreementButton
                officialSiteButton
                appVersionView
            }
            Section(mode.supportProjectSectionTitle) {
                workoutShopButton
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

    @ViewBuilder
    var profileSectionFooter: some View {
        switch self {
        case .authorized:
            EmptyView()
        case .incognito:
            Text(Constants.incognitoInfoText)
        }
    }

    var appInfoSectionTitle: String {
        self == .authorized ? "Информация о приложении" : "О приложении"
    }

    var supportProjectSectionTitle: String { "Поддержать проект" }
}

private extension ProfileSettingsView {
    var editAccountButton: some View {
        NavigationLink(destination: AccountInfoView(mode: .edit)) {
            Label("Редактировать данные", systemImage: "doc.badge.gearshape.fill")
        }
    }

    var changePasswordButton: some View {
        NavigationLink(destination: ChangePasswordView()) {
            Label("Изменить пароль", systemImage: "lock.fill")
        }
    }

    var logoutButton: some View {
        Button {
            showLogoutDialog.toggle()
        } label: {
            Label("Выйти", systemImage: "arrow.down.backward.circle.fill")
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

    var registerButton: some View {
        NavigationLink(destination: AccountInfoView(mode: .create)) {
            Label("Регистрация", systemImage: "person.badge.plus.fill")
                .font(.system(.body).bold())
        }
    }

    var authorizeButton: some View {
        NavigationLink(destination: LoginView()) {
            Label("Авторизация", systemImage: "arrow.forward.circle.fill")
                .font(.system(.body).bold())
        }
    }

    var feedbackButton: some View {
        Button { viewModel.feedbackAction() } label: {
            Label("Отправить обратную связь", systemImage: "envelope.fill")
        }
    }

    var rateAppButton: some View {
        Link(destination: Constants.appReviewURL) {
            Label("Оценить приложение", systemImage: "star.bubble.fill")
        }
    }

    var userAgreementButton: some View {
        Link(destination: Constants.RulesOfService.aboutApp) {
            Label("Пользовательское соглашение", systemImage: "doc.text.fill")
        }
    }

    var officialSiteButton: some View {
        Link(destination: Constants.officialSiteURL) {
            Label("Официальный сайт", systemImage: "w.circle.fill")
        }
    }

    var appVersionView: some View {
        HStack {
            Label("Версия", systemImage: "info.circle.fill")
            Spacer()
            Text(Constants.appVersion)
                .foregroundColor(.secondary)
        }
    }

    var workoutShopButton: some View {
        Link(destination: Constants.workoutShopURL) {
            Label("Магазин WORKOUT", systemImage: "bag.fill")
        }
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
