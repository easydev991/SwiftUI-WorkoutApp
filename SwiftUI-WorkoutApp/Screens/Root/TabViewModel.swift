import SWDesignSystem
import SwiftUI

final class TabViewModel: ObservableObject {
    @Published var selectedTab = Tab.map

    func selectTab(_ tab: Tab) { selectedTab = tab }
}

extension TabViewModel {
    enum Tab: Int, Hashable, CaseIterable {
        case map = 0, events, messages, profile, settings

        private var accessibilityId: String {
            switch self {
            case .map: "map"
            case .events: "events"
            case .messages: "messages"
            case .profile: "profile"
            case .settings: "settings"
            }
        }

        private var title: LocalizedStringKey {
            switch self {
            case .map:
                "Площадки"
            case .events:
                "Мероприятия"
            case .messages:
                "Сообщения"
            case .profile:
                "Профиль"
            case .settings:
                "Настройки"
            }
        }

        @ViewBuilder
        private var icon: some View {
            switch self {
            case .map:
                Image.parkTabIcon
            case .events:
                Icons.Tabbar.events.view
            case .messages:
                Icons.Tabbar.messages.view
            case .profile:
                Icons.Tabbar.profile.view
            case .settings:
                Icons.Tabbar.settings.view
            }
        }

        var tabItemLabel: some View {
            Label(
                title: { Text(title) },
                icon: { icon }
            )
            .environment(\.symbolVariants, .none)
            .accessibilityIdentifier(accessibilityId)
        }

        @MainActor @ViewBuilder
        var screen: some View {
            switch self {
            case .map:
                ParksMapScreen()
            case .events:
                EventsListScreen()
            case .messages:
                DialogsListScreen()
            case .profile:
                MainUserProfileScreen()
            case .settings:
                SettingsScreen()
            }
        }
    }
}
