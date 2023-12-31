import Foundation

@MainActor
public protocol DefaultsProtocol: AnyObject, Sendable {
    var appLanguage: AppLanguage { get }
    var appTheme: AppColorTheme { get }
    var mainUserInfo: UserResponse? { get }
    var mainUserCountryID: Int { get }
    var mainUserCityID: Int { get }
    var needUpdateUser: Bool { get }
    var isAuthorized: Bool { get }
    var friendRequestsList: [UserResponse] { get }
    var friendsIdsList: [Int] { get }
    var blacklistedUsers: [UserResponse] { get }
    var unreadMessagesCount: Int { get }
    /// Дефолтная дата - предыдущее ручное обновление файла `countries.json`
    var lastCountriesUpdateDate: Date { get }
    func setAppLanguage(_ language: AppLanguage)
    func setAppTheme(_ theme: AppColorTheme)
    func saveAuthData(_ info: AuthData) throws
    func basicAuthInfo() throws -> AuthData
    func setUserNeedUpdate(_ newValue: Bool)
    /// Обновляет `lastCountriesUpdateDate`
    func didUpdateCountries()
    func saveUserInfo(_ info: UserResponse) throws
    func saveFriendsIds(_ ids: [Int]) throws
    func saveFriendRequests(_ array: [UserResponse]) throws
    func saveUnreadMessagesCount(_ count: Int)
    func saveBlacklist(_ array: [UserResponse]) throws
    func updateBlacklist(option: BlacklistOption, user: UserResponse)
    func setHasJournals(_ hasJournals: Bool)
    func setHasParks(_ isAddedPark: Bool)
    func triggerLogout()
}

extension Date: RawRepresentable {
    public var rawValue: String {
        timeIntervalSinceReferenceDate.description
    }

    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
