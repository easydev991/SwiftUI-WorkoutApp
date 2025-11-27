import SWDesignSystem
import SwiftUI
import SWModels
import SWUtils

/// Экран с настройками и общей информацией о приложении
struct MoreScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    @Environment(\.locale) private var locale
    @State private var showLanguageAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    SectionView(header: "Настройки", mode: .regular) {
                        VStack(spacing: 0) {
                            appThemeButton
                            languagePicker
                            appIconButton
                        }
                    }
                    dividerView
                    SectionView(header: "О приложении", mode: .regular) {
                        VStack(spacing: 4) {
                            feedbackButton
                            rateAppButton
                            officialSiteButton
                            developerProfileButton
                            shareAppButton
                            appVersionView
                        }
                    }
                    dividerView
                    SectionView(header: "Другие приложения", mode: .regular) {
                        VStack(spacing: 4) {
                            sotkaButton
                            daysCounterButton
                        }
                    }
                    dividerView
                    SectionView(header: "Поддержать проект", mode: .regular) {
                        VStack(spacing: 4) {
                            workoutShopButton
                            githubButton
                        }
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
            .navigationTitle("Ещё")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension MoreScreen {
    enum Links {
        static let appReview = URL(string: "https://apps.apple.com/app/id6749501617?action=write-review")!
        static let workoutShop = URL(string: "https://workoutshop.ru//SWiOS")!
        static let developerBlog = URL(string: "https://t.me/easy_dev991")!
        static let githubLink = URL(string: "https://github.com/easydev991/SwiftUI-WorkoutApp")!
        static let officialSite = URL(string: "https://workout.su")!
        static let appStoreLink = URL(string: "https://apps.apple.com/app/id6749501617")
        static let sotkaStoreLink = URL(string: "https://apps.apple.com/app/id6753644091")!
        static let daysCounterStoreLink = URL(string: "https://apps.apple.com/app/id6744068216")!
    }
}

private extension MoreScreen {
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
                    Text($0.description).tag($0)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тема приложения"),
                trailingContent: .textWithChevron(defaults.appTheme.description)
            )
        }
    }

    var languagePicker: some View {
        Button {
            showLanguageAlert.toggle()
        } label: {
            let trailingText = AppLanguage.makeCurrentValue(locale.identifier).title
            ListRowView(
                leadingContent: .text("Язык приложения"),
                trailingContent: .textWithChevron(trailingText)
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

    var appIconButton: some View {
        NavigationLink(destination: AppIconScreen()) {
            ListRowView(
                leadingContent: .text("Иконка приложения"),
                trailingContent: .chevron
            )
        }
    }

    var feedbackButton: some View {
        Button {
            FeedbackSender.sendFeedback(
                subject: CommonFeedback.subject,
                messageBody: CommonFeedback.body,
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

    var sotkaButton: some View {
        Link(destination: Links.sotkaStoreLink) {
            ListRowView(
                leadingContent: .text("SOTKA"),
                trailingContent: .chevron
            )
        }
    }

    var daysCounterButton: some View {
        Link(destination: Links.daysCounterStoreLink) {
            ListRowView(
                leadingContent: .text("Счётчик дней"),
                trailingContent: .chevron
            )
        }
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

    var githubButton: some View {
        Link(destination: Links.githubLink) {
            ListRowView(
                leadingContent: .text("Ссылка на GitHub"),
                trailingContent: .chevron
            )
        }
    }

    @ViewBuilder
    var shareAppButton: some View {
        if let url = Links.appStoreLink {
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
    MoreScreen()
        .environmentObject(DefaultsService())
}
#endif
