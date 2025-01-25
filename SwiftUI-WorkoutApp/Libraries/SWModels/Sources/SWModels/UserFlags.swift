import Foundation

/// Содержит флаги пользователя для `Environment`
public struct UserFlags: Sendable {
    public let isAuthorized: Bool
    public let needUpdate: Bool
    public let hasParks: Bool
    public let hasFriends: Bool
    public let hasJournals: Bool

    public init(
        isAuthorized: Bool,
        needUpdate: Bool,
        hasParks: Bool,
        hasFriends: Bool,
        hasJournals: Bool
    ) {
        self.isAuthorized = isAuthorized
        self.needUpdate = needUpdate
        self.hasParks = hasParks
        self.hasFriends = hasFriends
        self.hasJournals = hasJournals
    }

    public static let defaultValue = Self(
        isAuthorized: false,
        needUpdate: false,
        hasParks: false,
        hasFriends: false,
        hasJournals: false
    )
}
