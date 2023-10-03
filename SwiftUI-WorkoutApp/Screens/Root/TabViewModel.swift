import DesignSystem
import SwiftUI

final class TabViewModel: ObservableObject {
    @Published var selectedTab = Tab.map

    func selectTab(_ tab: Tab) { selectedTab = tab }
}

extension TabViewModel {
    enum Tab: Int, Hashable, CaseIterable {
        case map = 0, events, messages, journal, profile

        private var title: LocalizedStringKey {
            switch self {
            case .map:
                "Площадки"
            case .events:
                "Мероприятия"
            case .messages:
                "Сообщения"
            case .journal:
                "Дневники"
            case .profile:
                "Профиль"
            }
        }

        @ViewBuilder
        private var icon: some View {
            switch self {
            case .map:
                Image.sportsGroundIcon
            case .events:
                Image(systemName: Icons.Tabbar.events.rawValue)
            case .messages:
                Image(systemName: Icons.Tabbar.messages.rawValue)
            case .journal:
                Image(systemName: Icons.Tabbar.journals.rawValue)
            case .profile:
                Image(systemName: Icons.Tabbar.profile.rawValue)
            }
        }

        var tabItemLabel: some View {
            Label(
                title: { Text(title) },
                icon: { icon }
            )
            .environment(\.symbolVariants, .none)
        }

        @ViewBuilder
        var screen: some View {
            switch self {
            case .map:
                SportsGroundsMapView()
            case .events:
                EventsListView()
            case .messages:
                DialogsScreen()
            case .journal:
                JournalsScreen()
            case .profile:
                ProfileScreen()
            }
        }
    }
}
