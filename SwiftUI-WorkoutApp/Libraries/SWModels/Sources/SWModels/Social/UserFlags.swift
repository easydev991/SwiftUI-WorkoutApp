import Foundation

/// Содержит некоторые флаги пользователя для `Environment`
///
/// Используется вместо `defaults`, где возможно
public struct UserFlags: Sendable {
    public let isAuthorized: Bool
    public let hasParks: Bool
    public let hasFriends: Bool

    public init(
        isAuthorized: Bool,
        hasParks: Bool,
        hasFriends: Bool
    ) {
        self.isAuthorized = isAuthorized
        self.hasParks = hasParks
        self.hasFriends = hasFriends
    }

    public static let defaultValue = Self(
        isAuthorized: false,
        hasParks: false,
        hasFriends: false
    )
}
