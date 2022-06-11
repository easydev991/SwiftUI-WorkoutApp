import Foundation
import UIKit.UIDevice

enum Constants {
    static let minPasswordSize = 6
    static let photosLimit = 15
    static let defaultUserAge = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    static let minUserAge = Calendar.current.date(byAdding: .year, value: -5, to: .now) ?? .now
    static let maxEventFutureDate = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    static let halfMinuteAgo = Calendar.current.date(byAdding: .second, value: -30, to: .now) ?? .now
    static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String).valueOrEmpty
    static let oldAppStoreAddress = "https://itunes.apple.com/us/app/jobsy/id1035159361"
    static let rulesOfService = "https://workout.su/pravila"

    enum Feedback {
        static let subject = "Обратная связь"
        static let toEmail = "info@workout.su"
        static let question = "Над чем нам стоит поработать?"
        static let sysVersion = "iOS: \(UIDevice.current.systemVersion)"
        static let appVersion = "App version: \(Constants.appVersion)"
        static var completeURL: URL? {
            let _subject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return .init(string: "mailto:\(toEmail)?subject=\(_subject.valueOrEmpty)")
        }
    }

    enum Alert {
        static let forgotPassword = "Для восстановления пароля введите логин или email"
        static let friendRequestSent = "Запрос отправлен!"
        static let deleteEvent = "Удалить мероприятие?"
        static let deleteGround = "Удалить площадку?"
        static let deleteJournal = "Удалить дневник?"
        static let deleteJournalEntry = "Удалить запись из дневника?"
        static let deleteDialog = "Удалить диалог?"
        static let logout = "Выйти из учетной записи?"
        static let deleteProfile = "Удалить учетную запись без возможности восстановления?"
        static let resetSuccessful = "Инструкция для восстановления пароля выслана на email, указанный при регистрации"
    }

    enum FriendAction: String {
        case sendFriendRequest = "Добавить в друзья"
        case removeFriend = "Удалить из друзей"
    }
}
