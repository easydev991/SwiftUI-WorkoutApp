import Foundation
import SWModels

extension SWClient {
    enum Endpoint {
        // MARK: Регистрация
        /// **POST** ${API}/registration
        case registration(form: MainUserForm)

        // MARK: Авторизация
        /// **POST** ${API}/auth/login
        case login

        // MARK: Восстановление пароля
        /// **POST** ${API}/auth/reset
        case resetPassword(login: String)

        // MARK: Изменить данные пользователя
        /// **POST** ${API}/users/<user_id>
        case editUser(id: Int, form: MainUserForm)

        // MARK: Изменить пароль
        /// **POST** ${API}/auth/changepass
        case changePassword(currentPass: String, newPass: String)

        // MARK: Удалить профиль текущего пользователя
        /// **DELETE** ${API}/users/current
        case deleteUser(auth: AuthData)

        // MARK: Получить профиль пользователя
        /// **GET** ${API}/users/<id>
        /// `id` - идентификатор пользователя, чей профиль нужно получить
        case getUser(id: Int)

        // MARK: Получить список друзей пользователя
        /// **GET** ${API}/users/<id>/friends
        /// `id` - идентификатор пользователя, чьих друзей нужно получить
        case getFriendsForUser(id: Int)

        // MARK: Получить список заявок на добавление в друзья
        /// **GET** ${API}/friends/requests
        case getFriendRequests

        // MARK: Принять заявку на добавление в друзья
        /// **POST** ${API}/friends/<id>/accept
        case acceptFriendRequest(from: Int)

        // MARK: Отклонить заявку на добавление в друзья
        /// **DELETE**  ${API}/friends/<user_id>/accept
        case declineFriendRequest(from: Int)

        // MARK: Отправить запрос на добавление в друзья
        /// **POST**  ${API}/friends/<user_id>
        case sendFriendRequest(to: Int)

        // MARK: Удалить пользователя из списка друзей
        /// **DELETE**  ${API}/friends/<user_id>
        case deleteFriend(_ friendID: Int)

        // MARK: Получить черный список пользователей
        /// **GET** ${API}/blacklist
        case getBlacklist

        // MARK: Добавить пользователя в черный список
        /// **POST** ${API}/blacklist/<user_id>
        case addToBlacklist(_ userID: Int)

        // MARK: Удалить пользователя из черного списка
        /// **DELETE** ${API}/blacklist/<user_id>
        case deleteFromBlacklist(_ userID: Int)

        // MARK: Найти пользователей по логину
        /// **GET** ${API}/users/search?name=<user>
        case findUsers(with: String)

        // MARK: Получить список всех площадок
        /// **GET** ${API}/areas?fields=short
        ///
        /// Возвращает список с кратким набором полей, т.к. при запросе всех данных сервер не справляется с нагрузкой
        case getAllSportsGrounds

        // MARK: Получить список площадок, обновленных после указанной даты
        /// **GET** ${API}/areas/last/<date>
        case getUpdatedSportsGrounds(from: String)

        // MARK: Получить выбранную площадку:
        /// **GET** ${API}/areas/<id>
        ///
        /// - Работает и с аутентификацией, и без
        /// - Для авторизованного пользователя нужно делать запрос с токеном,
        /// чтобы получить корректные данные (тренируется ли на площадке)
        case getSportsGround(id: Int)

        // MARK: Добавить новую спортплощадку
        /// **POST** ${API}/areas
        case createSportsGround(form: SportsGroundForm)

        // MARK: Изменить выбранную спортплощадку
        /// **POST** ${API}/areas/<id>
        case editSportsGround(id: Int, form: SportsGroundForm)

        // MARK: Удалить площадку
        /// **DELETE** ${API}/areas/<id>
        case deleteSportsGround(_ groundID: Int)

        // MARK: Добавить комментарий для площадки
        /// **POST** ${API}/areas/<area_id>/comments
        case addCommentToSportsGround(groundID: Int, comment: String)

        // MARK: Изменить свой комментарий для площадки
        /// **POST** ${API}/areas/<area_id>/comments/<comment_id>
        case editGroundComment(groundID: Int, commentID: Int, newComment: String)

        // MARK: Удалить свой комментарий для площадки
        /// **DELETE** ${API}/areas/<area_id>/comments/<comment_id>
        case deleteGroundComment(_ groundID: Int, commentID: Int)

        // MARK: Получить список площадок, где тренируется пользователь
        /// **GET** ${API}/users/<user_id>/areas
        case getSportsGroundsForUser(_ userID: Int)

        // MARK: Сообщить, что пользователь тренируется на площадке
        /// **POST** ${API}/areas/<area_id>/train
        case postTrainHere(_ groundID: Int)

        // MARK: Сообщить, что пользователь не тренируется на площадке
        /// **DELETE** ${API}/areas/<area_id>/train
        case deleteTrainHere(_ groundID: Int)

        // MARK: Получить список предстоящих мероприятий
        /// **GET** ${API}/trainings/current
        ///
        /// - Работает и с аутентификацией, и без
        /// - Для авторизованного пользователя нужно делать запрос с токеном,
        /// чтобы получить корректные данные (участие в мероприятии)
        case getFutureEvents

        // MARK: Получить краткий список прошедших мероприятий
        /// **GET** ${API}/trainings/last
        ///
        /// - Работает и с аутентификацией, и без
        /// - Для авторизованного пользователя нужно делать запрос с токеном,
        /// чтобы получить корректные данные (участие в мероприятии)
        case getPastEvents

        // MARK: Получить всю информацию о мероприятии
        /// **GET** ${API}/trainings/<event_id>
        case getEvent(id: Int)

        // MARK: Создать новое мероприятие
        /// **POST** ${API}/trainings
        case createEvent(form: EventForm)

        // MARK: Изменить существующее мероприятие
        /// **POST** ${API}/trainings/<id>
        case editEvent(id: Int, form: EventForm)

        // MARK: Сообщить, что пользователь пойдет на мероприятие
        /// **POST** ${API}/trainings/<event_id>/go
        case postGoToEvent(_ eventID: Int)

        // MARK: Сообщить, что пользователь не пойдет на мероприятие
        /// **DELETE** ${API}/trainings/<event_id>/go
        case deleteGoToEvent(_ eventID: Int)

        // MARK: Добавить комментарий для мероприятия
        /// **POST** ${API}/trainings/<event_id>/comments
        case addCommentToEvent(eventID: Int, comment: String)

        // MARK: Удалить свой комментарий для мероприятия
        /// **DELETE** ${API}/trainings/<event_id>/comments/<comment_id>
        case deleteEventComment(_ eventID: Int, commentID: Int)

        // MARK: Изменить свой комментарий для мероприятия
        /// **POST** ${API}/trainings/<training_id>/comments/<comment_id>
        case editEventComment(eventID: Int, commentID: Int, newComment: String)

        // MARK: Удалить мероприятие
        /// **DELETE** ${API}/trainings/<event_id>
        case deleteEvent(_ eventID: Int)

        // MARK: Получить список диалогов
        /// **GET** ${API}/dialogs
        case getDialogs

        // MARK: Получить сообщения в диалоге
        /// **GET** ${API}/dialogs/<dialog_id>/messages
        case getMessages(dialogID: Int)

        // MARK: Отправить сообщение пользователю
        /// **POST** ${API}/messages/<user_id>
        case sendMessageTo(_ message: String, _ userID: Int)

        // MARK: Отметить сообщения как прочитанные
        /// **POST** ${API}/messages/mark_as_read
        case markAsRead(from: Int)

        // MARK: Удалить выбранный диалог
        /// **DELETE** ${API}/dialogs/<dialog_id>
        case deleteDialog(id: Int)

        // MARK: Получить список дневников пользователя
        /// **GET** ${API}/users/<user_id>/journals
        case getJournals(userID: Int)

        // MARK: Получить дневник пользователя
        /// **GET** ${API}/users/<user_id>/journals/<journal_id>
        case getJournal(userID: Int, journalID: Int)

        // MARK: Изменить настройки дневника
        /// **PUT** ${API}/users/<user_id>/journals/<journal_id>
        case editJournalSettings(userID: Int, journalID: Int, title: String, viewAccess: Int, commentAccess: Int)

        // MARK: Создать новый дневник
        /// **POST** ${API}/users/<user_id>/journals
        case createJournal(userID: Int, title: String)

        // MARK: Получить записи из дневника пользователя
        /// **GET** ${API}/users/<user_id>/journals/<journal_id>/messages
        case getJournalEntries(userID: Int, journalID: Int)

        // MARK: Сохранить новую запись в дневнике пользователя
        /// **POST** ${API}/users/<user_id>/journals/<journal_id>/messages
        case saveJournalEntry(userID: Int, journalID: Int, message: String)

        // MARK: Изменить запись в дневнике пользователя
        /// **PUT** ${API}/users/<user_id>/journals/<journal_id>/messages/<id>
        case editEntry(userID: Int, journalID: Int, entryID: Int, newEntryText: String)

        // MARK: Удалить запись в дневнике пользователя
        /// **DELETE** ${API}/users/<user_id>/journals/<journal_id>/messages/<id>
        case deleteEntry(userID: Int, journalID: Int, entryID: Int)

        // MARK: Удалить дневник пользователя
        /// **DELETE** ${API}/users/<user_id>/journals/<journal_id>
        case deleteJournal(userID: Int, journalID: Int)

        // MARK: Удалить фото мероприятия
        /// **DELETE** ${API}/trainings/<event_id>/photos/<photo_id>
        case deleteEventPhoto(eventID: Int, photoID: Int)

        // MARK: Удалить фото площадки
        /// **DELETE** ${API}/areas/<area_id>/photos/<photo_id>
        case deleteGroundPhoto(groundID: Int, photoID: Int)

        /// Создает `URLRequest` с использованием базового `url`
        func urlRequest(with baseUrlString: String) -> URLRequest? {
            guard let url = URL(string: "\(baseUrlString)\(urlPath)") else { return nil }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = httpBody
            request.allHTTPHeaderFields = headers
            return request
        }
    }
}

private extension SWClient.Endpoint {
    var urlPath: String {
        switch self {
        case .registration:
            "/registration"
        case .login:
            "/auth/login"
        case .resetPassword:
            "/auth/reset"
        case let .editUser(userID, _):
            "/users/\(userID)"
        case .changePassword:
            "/auth/changepass"
        case .deleteUser:
            "/users/current"
        case let .getUser(id):
            "/users/\(id)"
        case let .getFriendsForUser(id):
            "/users/\(id)/friends"
        case .getFriendRequests:
            "/friends/requests"
        case let .acceptFriendRequest(userID),
             let .declineFriendRequest(userID):
            "/friends/\(userID)/accept"
        case let .sendFriendRequest(userID),
             let .deleteFriend(userID):
            "/friends/\(userID)"
        case .getBlacklist:
            "/blacklist"
        case let .addToBlacklist(userID),
             let .deleteFromBlacklist(userID):
            "/blacklist/\(userID)"
        case let .findUsers(name):
            "/users/search?name=\(name)"
        case .getAllSportsGrounds:
            "/areas?fields=short"
        case let .getUpdatedSportsGrounds(date):
            "/areas/last/\(date)"
        case .createSportsGround:
            "/areas"
        case let .getSportsGround(id),
             let .editSportsGround(id, _),
             let .deleteSportsGround(id):
            "/areas/\(id)"
        case let .addCommentToSportsGround(groundID, _):
            "/areas/\(groundID)/comments"
        case let .editGroundComment(groundID, commentID, _):
            "/areas/\(groundID)/comments/\(commentID)"
        case let .deleteGroundComment(groundID, commentID):
            "/areas/\(groundID)/comments/\(commentID)"
        case let .getSportsGroundsForUser(userID):
            "/users/\(userID)/areas"
        case let .postTrainHere(groundID), let .deleteTrainHere(groundID):
            "/areas/\(groundID)/train"
        case .getFutureEvents:
            "/trainings/current"
        case .getPastEvents:
            "/trainings/last"
        case let .getEvent(id):
            "/trainings/\(id)"
        case .createEvent:
            "/trainings"
        case let .postGoToEvent(id), let .deleteGoToEvent(id):
            "/trainings/\(id)/go"
        case let .addCommentToEvent(id, _):
            "/trainings/\(id)/comments"
        case let .deleteEventComment(eventID, commentID):
            "/trainings/\(eventID)/comments/\(commentID)"
        case let .editEventComment(eventID, commentID, _):
            "/trainings/\(eventID)/comments/\(commentID)"
        case let .deleteEvent(id), let .editEvent(id, _):
            "/trainings/\(id)"
        case .getDialogs:
            "/dialogs"
        case let .getMessages(dialogID):
            "/dialogs/\(dialogID)/messages"
        case let .sendMessageTo(_, userID):
            "/messages/\(userID)"
        case .markAsRead:
            "/messages/mark_as_read"
        case let .deleteDialog(dialogID):
            "/dialogs/\(dialogID)"
        case let .getJournals(userID),
             let .createJournal(userID, _):
            "/users/\(userID)/journals"
        case let .getJournal(userID, journalID),
             let .deleteJournal(userID, journalID),
             let .editJournalSettings(userID, journalID, _, _, _):
            "/users/\(userID)/journals/\(journalID)"
        case let .getJournalEntries(userID, journalID),
             let .saveJournalEntry(userID, journalID, _):
            "/users/\(userID)/journals/\(journalID)/messages"
        case let .editEntry(userID, journalID, entryID, _),
             let .deleteEntry(userID, journalID, entryID):
            "/users/\(userID)/journals/\(journalID)/messages/\(entryID)"
        case let .deleteEventPhoto(eventID, photoID):
            "/trainings/\(eventID)/photos/\(photoID)"
        case let .deleteGroundPhoto(groundID, photoID):
            "/areas/\(groundID)/photos/\(photoID)"
        }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    var method: HTTPMethod {
        switch self {
        case .registration, .login, .editUser, .resetPassword,
             .changePassword, .acceptFriendRequest, .sendFriendRequest,
             .addCommentToSportsGround, .editGroundComment, .postTrainHere,
             .createEvent, .editEvent, .postGoToEvent, .addToBlacklist,
             .addCommentToEvent, .editEventComment, .sendMessageTo,
             .createJournal, .markAsRead, .saveJournalEntry,
             .createSportsGround, .editSportsGround:
            .post
        case .getUser, .getFriendsForUser, .getFriendRequests,
             .getAllSportsGrounds, .getSportsGround,
             .findUsers, .getSportsGroundsForUser, .getBlacklist,
             .getFutureEvents, .getPastEvents, .getEvent,
             .getDialogs, .getMessages, .getJournals,
             .getJournal, .getJournalEntries,
             .getUpdatedSportsGrounds:
            .get
        case .declineFriendRequest, .deleteFriend, .deleteFromBlacklist,
             .deleteGroundComment, .deleteTrainHere,
             .deleteUser, .deleteGoToEvent,
             .deleteEventComment, .deleteEvent,
             .deleteDialog, .deleteJournal,
             .deleteEntry, .deleteSportsGround,
             .deleteEventPhoto, .deleteGroundPhoto:
            .delete
        case .editJournalSettings, .editEntry:
            .put
        }
    }

    enum HTTPHeader {
        static let boundary = "FFF"
        enum Key: String { case contentType = "Content-Type" }
        static var withMultipartFormData: [String: String] {
            [Key.contentType.rawValue: "multipart/form-data; boundary=\(boundary)"]
        }
    }

    var headers: [String: String] {
        switch self {
        case .createSportsGround, .editSportsGround, .createEvent, .editEvent:
            return HTTPHeader.withMultipartFormData
        default: return [:]
        }
    }

    enum Parameter {
        enum Key: String {
            case name, fullname, email, password,
                 comment, message, title, description,
                 date, address, latitude, longitude
            case areaID = "area_id"
            case viewAccess = "view_access"
            case commentAccess = "comment_access"
            case genderCode = "gender"
            case usernameOrEmail = "username_or_email"
            case newPassword = "new_password"
            case countryID = "country_id"
            case cityID = "city_id"
            case birthDate = "birth_date"
            case fromUserID = "from_user_id"
            case typeID = "type_id"
            case classID = "class_id"
        }

        static func makeBody(from dict: [Key: String]) -> Data? {
            dict
                .map { $0.key.rawValue + "=" + $0.value }
                .joined(separator: "&")
                .data(using: .utf8)
        }

        static func makeBodyWithMultipartForm(from dict: [Key: String], with media: [MediaFile]?) -> Data {
            let boundary = HTTPHeader.boundary
            let lineBreak = "\r\n"
            var body = Data()
            dict.forEach { key, value in
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key.rawValue)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
            media?.forEach { photo in
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
            body.append("--\(boundary)--\(lineBreak)")
            return body
        }
    }

    var httpBody: Data? {
        switch self {
        case .login, .getUser, .getFriendsForUser, .getFriendRequests,
             .acceptFriendRequest, .declineFriendRequest, .findUsers,
             .sendFriendRequest, .deleteFriend, .getBlacklist,
             .addToBlacklist, .deleteFromBlacklist,
             .getSportsGround, .deleteGroundComment, .getSportsGroundsForUser,
             .postTrainHere, .deleteTrainHere, .deleteUser,
             .getFutureEvents, .getPastEvents, .getEvent,
             .postGoToEvent, .deleteGoToEvent,
             .deleteEventComment, .deleteEvent, .getDialogs,
             .getMessages, .deleteDialog, .getJournals,
             .getJournal, .getJournalEntries, .deleteEntry,
             .deleteJournal, .getAllSportsGrounds,
             .getUpdatedSportsGrounds, .deleteSportsGround,
             .deleteEventPhoto, .deleteGroundPhoto:
            return nil
        case let .registration(form):
            return Parameter.makeBody(
                from: [
                    .name: form.userName,
                    .fullname: form.fullName,
                    .email: form.email,
                    .password: form.password,
                    .genderCode: form.genderCode.description,
                    .countryID: form.country.id,
                    .cityID: form.city.id,
                    .birthDate: form.birthDateIsoString
                ]
            )
        case let .editUser(_, form):
            return Parameter.makeBody(
                from: [
                    .name: form.userName,
                    .fullname: form.fullName,
                    .email: form.email,
                    .genderCode: form.genderCode.description,
                    .countryID: form.country.id,
                    .cityID: form.city.id,
                    .birthDate: form.birthDateIsoString
                ]
            )
        case let .resetPassword(login):
            return Parameter.makeBody(from: [.usernameOrEmail: login])
        case let .changePassword(current, new):
            return Parameter.makeBody(from: [.password: current, .newPassword: new])
        case let .addCommentToSportsGround(_, comment),
             let .addCommentToEvent(_, comment),
             let .editGroundComment(_, _, comment),
             let .editEventComment(_, _, comment):
            return Parameter.makeBody(from: [.comment: comment])
        case let .sendMessageTo(message, _):
            return Parameter.makeBody(from: [.message: message])
        case let .markAsRead(userID):
            return Parameter.makeBody(from: [.fromUserID: userID.description])
        case let .createJournal(_, title):
            return Parameter.makeBody(from: [.title: title])
        case let .saveJournalEntry(_, _, message),
             let .editEntry(_, _, _, message):
            return Parameter.makeBody(from: [.message: message])
        case let .editJournalSettings(_, _, title, viewAccess, commentAccess):
            return Parameter.makeBody(
                from: [
                    .title: title,
                    .viewAccess: viewAccess.description,
                    .commentAccess: commentAccess.description
                ]
            )
        case let .createEvent(form), let .editEvent(_, form):
            let params = Parameter.makeBodyWithMultipartForm(
                from: [
                    .title: form.title,
                    .description: form.description,
                    .date: form.dateIsoString,
                    .areaID: form.sportsGround.id.description
                ],
                with: form.newMediaFiles
            )
            return params
        case let .createSportsGround(form), let .editSportsGround(_, form):
            return Parameter.makeBodyWithMultipartForm(
                from: [
                    .address: form.address,
                    .latitude: form.latitude,
                    .longitude: form.longitude,
                    .cityID: form.cityID.description,
                    .typeID: form.typeID.description,
                    .classID: form.sizeID.description
                ],
                with: form.newMediaFiles
            )
        }
    }
}
