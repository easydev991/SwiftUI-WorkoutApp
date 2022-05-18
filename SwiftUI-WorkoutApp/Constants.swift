//
//  Constants.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import UIKit.UIDevice

struct Constants {
    static let minPasswordSize = 6
    static let defaultUserAge = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    static let minUserAge = Calendar.current.date(byAdding: .year, value: -5, to: .now) ?? .now
    static let maxEventFutureYear = 1
    static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String).valueOrEmpty
    static let oldAppStoreAddress = "https://itunes.apple.com/us/app/jobsy/id1035159361"
    static let rulesOfService = "https://workout.su/pravila"

    struct Feedback {
        static let subject = "Обратная связь"
        static let toEmail = "info@workout.su"
        static let question = "Над чем нам стоит поработать?"
        static let sysVersion = "iOS: \(UIDevice.current.systemVersion)"
        static let appVersion = "App version: \(Constants.appVersion)"
        static func completeURL() -> URL? {
            let _subject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return .init(string: "mailto:\(toEmail)?subject=\(_subject.valueOrEmpty)")
        }
    }

    struct API {
        static let baseURL = "https://workout.su/api/v3"
        static let timeOut = TimeInterval(15)
        static let codeOK = 200
    }

    struct Alert {
        static let success = "Успех!"
        static let error = "Ошибка"
        static let authError = "Ошибка авторизации"
        static let forgotPassword = "Для восстановления пароля введите логин или email"
        static let friendRequestSent = "Запрос отправлен!"
        static let eventCreated = "Мероприятие создано!"
        static let passwordChanged = "Пароль успешно изменен"
        static let logout = "Выйти из учетной записи?"
        static let deleteProfile = "Удалить учетную запись без возможности восстановления?"
        static let resetSuccessful = "Инструкция для восстановления пароля выслана на email, указанный при регистрации"
        static let resetPasswordError = "Не удалось восстановить пароль"
        static let changePasswordError = "Не удалось изменить пароль"
        static let cannotReadData = "Не удается прочитать загруженные данные"
    }

    enum Gender: String, CaseIterable, CustomStringConvertible, Codable {
        case male = "Мужской"
        case female = "Женский"
        init(_ code: Int?) {
            self = code == .zero ? .male : .female
        }
        var code: Int {
            self == .male ? .zero : 1
        }
        var description: String {
            self == .male ? "Мужчина" : "Женщина"
        }
    }

    enum FriendAction: String {
        case sendFriendRequest = "Добавить в друзья"
        case removeFriend = "Удалить из друзей"
    }

    enum BubblePosition { case incoming, sent }
}
