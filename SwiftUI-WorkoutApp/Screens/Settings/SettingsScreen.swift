import SWDesignSystem
import SwiftUI
import SWModels

/// Экран с настройками профиля основного пользователя
struct SettingsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    @State private var showLanguageAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    SectionView(header: "Внешний вид", mode: .regular) {
                        VStack(spacing: 0) {
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
                            developerProfileButton
                            shareAppButton
                            appVersionView
                        }
                    }
                    dividerView
                    SectionView(header: "Поддержать проект", mode: .regular) {
                        workoutShopButton
                    }
                    #if DEBUG
                    dividerView
                    NavigationLink(destination: LoggerScreen()) {
                        ListRowView(
                            leadingContent: .text("Логи"),
                            trailingContent: .chevron
                        )
                    }
                    #endif
                }
                .padding()
            }
            .background(Color.swBackground)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension SettingsScreen {
    enum Links {
        static let appReview = URL(string: "https://apps.apple.com/app/id1035159361?action=write-review")!
        static let workoutShop = URL(string: "https://workoutshop.ru//SWiOS")!
        static let developerBlog = URL(string: "https://t.me/easy_dev991")!
        static let officialSite = URL(string: "https://workout.su")!
        static let rulesOfService = URL(string: "https://workout.su/pravila")!
        static let appStoreLink = URL(string: "https://apps.apple.com/app/id1035159361")
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

private extension SettingsScreen {
    var dividerView: some View {
        SWDivider()
            .padding(.top, 4)
            .padding(.bottom, 24)
            .padding(.horizontal, -16)
    }

    var appThemeButton: some View {
        Menu {
            Picker(
                "",
                selection: .init(
                    get: { defaults.appTheme },
                    set: { defaults.setAppTheme($0) }
                )
            ) {
                ForEach(AppColorTheme.allCases) {
                    Text(.init($0.rawValue)).tag($0)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тема приложения"),
                trailingContent: .textWithChevron(defaults.appTheme.rawValue)
            )
        }
    }

    var languagePicker: some View {
        Button {
            showLanguageAlert.toggle()
        } label: {
            ListRowView(
                leadingContent: .text("Язык приложения"),
                trailingContent: .chevron
            )
        }
        .alert("Язык можно поменять в настройках телефона", isPresented: $showLanguageAlert) {
            Button("Отмена", role: .cancel) {
                showLanguageAlert.toggle()
            }
            Button("Перейти") {
                URLOpener.open(URL(string: UIApplication.openSettingsURLString))
            }
        }
    }

    var feedbackButton: some View {
        Button {
            FeedbackSender.sendFeedback(
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

    var developerProfileButton: some View {
        Link(destination: Links.developerBlog) {
            ListRowView(
                leadingContent: .text("Разработчик приложения"),
                trailingContent: .chevron
            )
        }
    }

    @ViewBuilder
    var shareAppButton: some View {
        if #available(iOS 16.0, *), let url = Links.appStoreLink {
            ShareLink(item: url) {
                ListRowView(
                    leadingContent: .text("Поделиться приложением"),
                    trailingContent: .chevron
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsScreen()
        .environmentObject(DefaultsService())
}
#endif
