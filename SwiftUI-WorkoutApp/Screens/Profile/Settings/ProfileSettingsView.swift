import FeedbackSender
import DesignSystem
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
        ScrollView {
            VStack(spacing: 14) {
                SectionView(header: "Профиль", mode: .regular) {
                    VStack(spacing: 0) {
                        if mode == .authorized {
                            changePasswordButton
                        } else {
                            authorizeView
                        }
                        appThemeButton
                    }
                }
                SWDivider(ignoreDefaultHorizontalPadding: true)
                SectionView(header: "О приложении", mode: .regular) {
                    VStack(spacing: 4) {
                        feedbackButton
                        rateAppButton
                        userAgreementButton
                        officialSiteButton
                        appVersionView
                    }
                }
                SWDivider(ignoreDefaultHorizontalPadding: true)
                SectionView(header: "Поддержать проект", mode: .regular) {
                    workoutShopButton
                }
                SWDivider(ignoreDefaultHorizontalPadding: true)
                SectionView(header: "Поддержать разработчика", mode: .regular) {
                    developerProfileButton
                }
                SWDivider(ignoreDefaultHorizontalPadding: true)
                logoutButton
            }
            .padding(.top, 14)
            .padding(.horizontal)
        }
        .background(Color.swBackground)
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
                .font(.subheadline)
                .foregroundColor(.swSmallElements)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
    var changePasswordButton: some View {
        NavigationLink(destination: ChangePasswordView()) {
            ListRowView(leadingContent: .text("Изменить пароль"), trailingContent: .chevron)
        }
        .padding(.bottom, 4)
    }

    var appThemeButton: some View {
        NavigationLink(destination: AppThemeScreen()) {
            ListRowView(
                leadingContent: .text("Тема приложения"),
                trailingContent: .textWithChevron(defaults.appTheme.rawValue)
            )
        }
    }

    var logoutButton: some View {
        Button {
            showLogoutDialog.toggle()
        } label: {
            ListRowView(leadingContent: .text("Выйти из профиля"))
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

    var authorizeView: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: LoginView()) {
                ListRowView(
                    leadingContent: .text("Авторизация"),
                    trailingContent: .chevron
                )
            }
            mode.profileSectionFooter
        }
        .padding(.bottom, 14)
    }

    var feedbackButton: some View {
        Button {
            feedbackSender.sendFeedback(
                subject: Feedback.subject,
                messageBody: Feedback.body,
                recipients: Constants.feedbackRecipient
            )
        } label: {
            ListRowView(leadingContent: .text("Отправить обратную связь"))
        }
    }

    var rateAppButton: some View {
        Link(destination: Links.appReview) {
            ListRowView(leadingContent: .text("Оценить приложение"))
        }
    }

    var userAgreementButton: some View {
        Link(destination: Links.rulesOfService) {
            ListRowView(leadingContent: .text("Пользовательское соглашение"))
        }
    }

    var officialSiteButton: some View {
        Link(destination: Links.officialSite) {
            ListRowView(leadingContent: .text("Официальный сайт"))
        }
    }

    var appVersionView: some View {
        ListRowView(
            leadingContent: .text("Версия"),
            trailingContent: .text(Constants.appVersion)
        )
    }

    var workoutShopButton: some View {
        Link(destination: Links.workoutShop) {
            ListRowView(leadingContent: .text("Магазин WORKOUT"))
        }
    }

    var developerProfileButton: some View {
        Link(destination: Links.developerProfile) {
            ListRowView(leadingContent: .text("Oleg991 на boosty"))
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
