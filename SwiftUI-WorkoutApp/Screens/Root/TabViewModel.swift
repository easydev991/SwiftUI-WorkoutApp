import Foundation

final class TabViewModel: ObservableObject {
    @Published var selectedTab = Tab.map

    func selectTab(_ tab: Tab) { selectedTab = tab }
}

extension TabViewModel {
    enum Tab: Int, Hashable {
        case map = 0, events, messages, journal, profile

        var title: String {
            switch self {
            case .map:
                return "Площадки"
            case .events:
                return "Мероприятия"
            case .messages:
                return "Сообщения"
            case .journal:
                return "Дневники"
            case .profile:
                return "Профиль"
            }
        }
    }
}
