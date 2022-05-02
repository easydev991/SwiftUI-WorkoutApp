//
//  Constants.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import UIKit.UIDevice

struct Constants {
    static let minimumUserAge = -5
    static let maxEventFutureYear = 1
    static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    static let oldAppStoreAddress = "https://itunes.apple.com/us/app/jobsy/id1035159361"
    static let rulesOfService = "https://workout.su/pravila"

    struct Feedback {
        static let subject = "Обратная связь"
        static let toEmail = "info@workout.su"
        static let question = "Над чем нам стоит поработать?"
        static let sysVersion = "iOS: \(UIDevice.current.systemVersion)"
        static let appVersion = "App version: \(Constants.appVersion)"
        static func completeURL() -> URL? {
            let _subject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            return .init(string: "mailto:\(toEmail)?subject=\(_subject)")
        }
    }
    struct API {
        static let baseURL = "https://workout.su/api/v3"
        static let timeOut = TimeInterval(20)
    }
    struct AlertTitle {
        static let authError = "Ошибка авторизации"
        static let forgotPassword = "Для восстановления пароля введите логин или email"
        static let commentSent = "Комментарий отправлен!"
        static let friendRequestSent = "Запрос отправлен!"
        static let eventCreated = "Мероприятие создано!"
        static let passwordChanged = "Пароль успешно изменен"
        static let logout = "Выйти из учетной записи?"
    }
    enum Gender: String, CaseIterable {
        case male = "Мужской"
        case female = "Женский"
        init(_ code: Int?) {
            self = code == .zero ? .male : .female
        }
    }
}
