import DesignSystem
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
        ScrollView {
            VStack(spacing: 0) {
                SectionView(header: "Профиль", mode: .regular) {
                    VStack(spacing: 0) {
                        switch mode {
                        case .authorized:
                            changePasswordButton
                        case .incognito:
                            authorizeView
                        }
                        appThemeButton
                        languagePicker
                    }
                }
                dividerView
                SectionView(header: "О приложении", mode: .regular) {
                    VStack(spacing: 4) {
                        feedbackButton
                        rateAppButton
                        userAgreementButton
                        officialSiteButton
                        appVersionView
                    }
                }
                dividerView
                SectionView(header: "Поддержать проект", mode: .regular) {
                    VStack(spacing: 4) {
                        workoutShopButton
                        workoutProfileButton
                    }
                }
                dividerView
                SectionView(header: "Поддержать разработчика", mode: .regular) {
                    developerProfileButton
                }
                dividerView
                logoutButton
            }
            .padding()
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
    var title: LocalizedStringKey {
        self == .authorized ? "Настройки" : "Информация"
    }

    @ViewBuilder
    var profileSectionFooter: some View {
        switch self {
        case .authorized:
            EmptyView()
        case .incognito:
            Text(.init(Constants.registrationInfoText))
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
        static let workoutShop = URL(string: "https://workoutshop.ru//SWiOS")!
        static let workoutProfile = URL(string: "https://boosty.to/swrussia")!
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
    var dividerView: some View {
        SWDivider()
            .padding(.top, 4)
            .padding(.bottom, 24)
            .padding(.horizontal, -16)
    }

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

    var languagePicker: some View {
        Menu {
            Picker(
                "",
                selection: .init(
                    get: { defaults.appLanguage.rawValue },
                    set: { defaults.setAppLanguage($0) }
                )
            ) {
                ForEach(AppLanguage.allCases.map(\.rawValue), id: \.self) {
                    Text(.init($0))
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Язык"),
                trailingContent: .textWithChevron(defaults.appLanguage.rawValue)
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
            .init(Constants.Alert.logout),
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
            ListRowView(
                leadingContent: .text("Отправить обратную связь"),
                trailingContent: .chevron
            )
        }
    }

    var rateAppButton: some View {
        Link(destination: Links.appReview) {
            ListRowView(
                leadingContent: .text("Оценить приложение"),
                trailingContent: .chevron
            )
        }
    }

    var userAgreementButton: some View {
        Link(destination: Links.rulesOfService) {
            ListRowView(
                leadingContent: .text("Пользовательское соглашение"),
                trailingContent: .chevron
            )
        }
    }

    var officialSiteButton: some View {
        Link(destination: Links.officialSite) {
            ListRowView(
                leadingContent: .text("Официальный сайт"),
                trailingContent: .chevron
            )
        }
    }

    var appVersionView: some View {
        ListRowView(
            leadingContent: .text("Версия"),
            trailingContent: .text(.init(Constants.appVersion))
        )
    }

    var workoutShopButton: some View {
        Link(destination: Links.workoutShop) {
            ListRowView(
                leadingContent: .text("Магазин WORKOUT"),
                trailingContent: .chevron
            )
        }
    }

    var workoutProfileButton: some View {
        Link(destination: Links.workoutProfile) {
            ListRowView(
                leadingContent: .text("Street Workout на boosty"),
                trailingContent: .chevron
            )
        }
    }

    var developerProfileButton: some View {
        Link(destination: Links.developerProfile) {
            ListRowView(
                leadingContent: .text("Oleg991 на boosty"),
                trailingContent: .chevron
            )
        }
    }
}

#if DEBUG
#Preview {
    ForEach(ProfileSettingsView.Mode.allCases, id: \.self) { mode in
        NavigationView {
            ProfileSettingsView(mode: mode)
        }
        .previewDisplayName(mode == .authorized ? "Авторизованный" : "Инкогнито")
    }
    .environmentObject(DefaultsService())
}
#endif
