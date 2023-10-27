import Foundation

@MainActor
public protocol DefaultsProtocol: AnyObject {
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
    /// Дефолтная дата - предыдущее ручное обновление файла `oldSportsGrounds.json`
    ///
    /// - При обновлении справочника вручную необходимо обновить тут дату
    /// - Неудобно, зато спасаемся от ошибок 500 при запросе слишком старых данных
    var lastGroundsUpdateDateString: String { get }
    /// Дефолтная дата - предыдущее ручное обновление файла `countries.json`
    var lastCountriesUpdateDate: Date { get }
    func setAppLanguage(_ language: AppLanguage)
    func setAppTheme(_ theme: AppColorTheme)
    func saveAuthData(_ info: AuthData) throws
    func basicAuthInfo() throws -> AuthData
    func setUserNeedUpdate(_ newValue: Bool)
    /// Обновляет `lastGroundsUpdateDateString`
    func didUpdateGrounds()
    /// Обновляет `lastCountriesUpdateDate`
    func didUpdateCountries()
    func saveUserInfo(_ info: UserResponse) throws
    func saveFriendsIds(_ ids: [Int]) throws
    func saveFriendRequests(_ array: [UserResponse]) throws
    func saveUnreadMessagesCount(_ count: Int)
    func saveBlacklist(_ array: [UserResponse]) throws
    func setHasJournals(_ hasJournals: Bool)
    func setHasSportsGrounds(_ isAddedGround: Bool)
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
