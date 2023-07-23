import FeedbackSender
import SwiftUI
import SWModels

/// Экран с настройками профиля основного пользователя
struct ProfileSettingsView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @State private var showLogoutDialog = false
    private let feedbackSender: FeedbackSender
    private let mode: Mode
    
    init(mode: Mode, feedbackSender: FeedbackSender = FeedbackSenderImp()) {
        self.mode = mode
        self.feedbackSender = feedbackSender
    }

    var body: some View {
        List {
            Section {
                if mode == .authorized {
                    editAccountButton
                    changePasswordButton
                } else {
                    authorizeButton
                }
                appThemeButton
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
            Section("Поддержать проект") {
                workoutShopButton
            }
            Section("Поддержать разработчика") {
                developerProfileButton
            }
            logoutButton
        }
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
            Text(Constants.registrationInfoText)
        }
    }

    var appInfoSectionTitle: String {
        self == .authorized ? "Информация о приложении" : "О приложении"
    }
}

private extension ProfileSettingsView {
    enum Links {
        static let appReview = URL(string: "https://apps.apple.com/app/id1035159361?action=write-review")!
        static let workoutShop = URL(string: "https://workoutshop.ru")!
        static let developerProfile = URL(string: "https://boosty.to/oleg991")!
        static let officialSite = URL(string: "https://workout.su")!
        static let rulesOfService = URL(string: "https://workout.su/pravila")!
    }
    
    enum Feedback {
        static let subject = "\(ProcessInfo.processInfo.processName): Обратная связь"
        static let body = """
            \(Feedback.sysVersion)
            \(Feedback.appVersion)
            \(Feedback.question)
            \n
        """
        private static let question = "Над чем нам стоит поработать?"
        private static let sysVersion = "iOS: \(ProcessInfo.processInfo.operatingSystemVersionString)"
        private static let appVersion = "App version: \(Constants.appVersion)"
    }
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

    var appThemeButton: some View {
        NavigationLink(destination: AppThemeScreen()) {
            Text("Тема приложения")
                .badge(defaults.appTheme.rawValue)
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

    var authorizeButton: some View {
        NavigationLink(destination: LoginView()) {
            Label("Авторизация", systemImage: "arrow.forward.circle.fill")
                .font(.system(.body).bold())
        }
    }

    var feedbackButton: some View {
        Button {
            feedbackSender.sendFeedback(
                subject: Feedback.subject,
                messageBody: Feedback.body,
                recipients: Constants.feedbackRecipient
            )
        } label: {
            Label("Отправить обратную связь", systemImage: "envelope.fill")
        }
    }

    var rateAppButton: some View {
        Link(destination: Links.appReview) {
            Label("Оценить приложение", systemImage: "star.bubble.fill")
        }
    }

    var userAgreementButton: some View {
        Link(destination: Links.rulesOfService) {
            Label("Пользовательское соглашение", systemImage: "doc.text.fill")
        }
    }

    var officialSiteButton: some View {
        Link(destination: Links.officialSite) {
            Label("Официальный сайт", systemImage: "w.circle.fill")
        }
    }

    var appVersionView: some View {
        Label("Версия", systemImage: "info.circle.fill")
            .badge(Constants.appVersion)
    }

    var workoutShopButton: some View {
        Link(destination: Links.workoutShop) {
            Label("Магазин WORKOUT", systemImage: "bag.fill")
        }
    }

    var developerProfileButton: some View {
        Link(destination: Links.developerProfile) {
            Label("Oleg991 на boosty", systemImage: "figure.wave")
        }
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
