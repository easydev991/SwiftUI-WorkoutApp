import DesignSystem
import FeedbackSender
import SwiftUI
import SWModels

/// Экран с настройками профиля основного пользователя
struct SettingsView: View {
    @EnvironmentObject private var defaults: DefaultsService
    private let feedbackSender: FeedbackSender = FeedbackSenderImp()

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
                }
                .padding()
            }
            .background(Color.swBackground)
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension SettingsView {
    enum Mode: CaseIterable {
        case authorized, incognito

        var title: LocalizedStringKey {
            self == .authorized ? "Настройки" : "Информация"
        }
    }
}

private extension SettingsView {
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

private extension SettingsView {
    var mode: Mode {
        defaults.isAuthorized ? .authorized : .incognito
    }

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
                    set: {
                        defaults.setAppTheme($0)
                        AppThemeService.set($0)
                    }
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
        Menu {
            Picker(
                "",
                selection: .init(
                    get: { defaults.appLanguage },
                    set: { defaults.setAppLanguage($0) }
                )
            ) {
                ForEach(AppLanguage.allCases, id: \.self) {
                    Text(.init($0.rawValue)).tag($0)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Язык"),
                trailingContent: .textWithChevron(defaults.appLanguage.rawValue)
            )
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
    NavigationView {
        SettingsView()
    }
    .environmentObject(DefaultsService())
}
#endif
