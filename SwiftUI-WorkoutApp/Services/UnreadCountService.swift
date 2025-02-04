import Foundation
import SWNetworkClient

struct UnreadCountService {
    let client: SWClient

    func getUnreadCount() async -> Int? {
        guard let dialogs = try? await client.getDialogs() else { return nil }
        return dialogs.map(\.unreadMessagesCount).reduce(0, +)
    }
}
