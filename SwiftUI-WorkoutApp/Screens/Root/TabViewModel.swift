import Foundation

final class TabViewModel: ObservableObject {
    @Published var selectedTab = Tab.events

    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}
