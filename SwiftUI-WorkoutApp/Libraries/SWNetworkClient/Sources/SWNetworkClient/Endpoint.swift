import Foundation
import SWModels
import SWNetwork

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
    case deleteUser

    // MARK: Получить профиль пользователя
    /// **GET** ${API}/users/<user_id>
    /// `id` - идентификатор пользователя, чей профиль нужно получить
    case getUser(id: Int)

    // MARK: Получить список друзей пользователя
    /// **GET** ${API}/users/<user_id>/friends
    /// `id` - идентификатор пользователя, чьих друзей нужно получить
    case getFriendsForUser(id: Int)

    // MARK: Получить список заявок на добавление в друзья
    /// **GET** ${API}/friends/requests
    case getFriendRequests

    // MARK: Принять заявку на добавление в друзья
    /// **POST** ${API}/friends/<user_id>/accept
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
    /// **GET** ${API}/users/search?name=<user_login>
    case findUsers(with: String)

    // MARK: Получить список стран/городов
    /// **GET** ${API}/countries
    case getCountries

    // MARK: Получить список всех площадок
    /// **GET** ${API}/areas?fields=short
    ///
    /// Возвращает список с кратким набором полей, т.к. при запросе всех данных сервер не справляется с нагрузкой
    case getAllParks

    // MARK: Получить список площадок, обновленных после указанной даты
    /// **GET** ${API}/areas/last/<date>
    case getUpdatedParks(from: String)

    // MARK: Получить выбранную площадку:
    /// **GET** ${API}/areas/<area_id>
    ///
    /// - Работает и с аутентификацией, и без
    /// - Для авторизованного пользователя нужно делать запрос с токеном,
    /// чтобы получить корректные данные (тренируется ли на площадке)
    case getPark(id: Int)

    // MARK: Добавить новую площадку
    /// **POST** ${API}/areas
    case createPark(form: ParkForm)

    // MARK: Изменить выбранную площадку
    /// **POST** ${API}/areas/<area_id>
    case editPark(id: Int, form: ParkForm)

    // MARK: Удалить площадку
    /// **DELETE** ${API}/areas/<area_id>
    case deletePark(_ parkID: Int)

    // MARK: Добавить комментарий для площадки
    /// **POST** ${API}/areas/<area_id>/comments
    case addCommentToPark(parkID: Int, comment: String)

    // MARK: Изменить свой комментарий для площадки
    /// **POST** ${API}/areas/<area_id>/comments/<comment_id>
    case editParkComment(parkID: Int, commentID: Int, newComment: String)

    // MARK: Удалить свой комментарий для площадки
    /// **DELETE** ${API}/areas/<area_id>/comments/<comment_id>
    case deleteParkComment(_ parkID: Int, commentID: Int)

    // MARK: Получить список площадок, где тренируется пользователь
    /// **GET** ${API}/users/<user_id>/areas
    case getParksForUser(_ userID: Int)

    // MARK: Сообщить, что пользователь тренируется на площадке
    /// **POST** ${API}/areas/<area_id>/train
    case postTrainHere(_ parkID: Int)

    // MARK: Сообщить, что пользователь не тренируется на площадке
    /// **DELETE** ${API}/areas/<area_id>/train
    case deleteTrainHere(_ parkID: Int)

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
    /// **POST** ${API}/trainings/<event_id>
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
    /// **POST** ${API}/trainings/<event_id>/comments/<comment_id>
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
    /// **PUT** ${API}/users/<user_id>/journals/<journal_id>/messages/<entry_id>
    case editEntry(userID: Int, journalID: Int, entryID: Int, newEntryText: String)

    // MARK: Удалить запись в дневнике пользователя
    /// **DELETE** ${API}/users/<user_id>/journals/<journal_id>/messages/<entry_id>
    case deleteEntry(userID: Int, journalID: Int, entryID: Int)

    // MARK: Удалить дневник пользователя
    /// **DELETE** ${API}/users/<user_id>/journals/<journal_id>
    case deleteJournal(userID: Int, journalID: Int)

    // MARK: Удалить фото мероприятия
    /// **DELETE** ${API}/trainings/<event_id>/photos/<photo_id>
    case deleteEventPhoto(eventID: Int, photoID: Int)

    // MARK: Удалить фото площадки
    /// **DELETE** ${API}/areas/<area_id>/photos/<photo_id>
    case deleteParkPhoto(parkID: Int, photoID: Int)
}

extension Endpoint {
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
        case .findUsers:
            "/users/search"
        case .getCountries:
            "/countries"
        case .getAllParks:
            "/areas"
        case let .getUpdatedParks(date):
            "/areas/last/\(date)"
        case .createPark:
            "/areas"
        case let .getPark(id),
             let .editPark(id, _),
             let .deletePark(id):
            "/areas/\(id)"
        case let .addCommentToPark(parkID, _):
            "/areas/\(parkID)/comments"
        case let .editParkComment(parkID, commentID, _):
            "/areas/\(parkID)/comments/\(commentID)"
        case let .deleteParkComment(parkID, commentID):
            "/areas/\(parkID)/comments/\(commentID)"
        case let .getParksForUser(userID):
            "/users/\(userID)/areas"
        case let .postTrainHere(parkID), let .deleteTrainHere(parkID):
            "/areas/\(parkID)/train"
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
        case let .deleteParkPhoto(parkID, photoID):
            "/areas/\(parkID)/photos/\(photoID)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .registration, .login, .editUser, .resetPassword,
             .changePassword, .acceptFriendRequest, .sendFriendRequest,
             .addCommentToPark, .editParkComment, .postTrainHere,
             .createEvent, .editEvent, .postGoToEvent, .addToBlacklist,
             .addCommentToEvent, .editEventComment, .sendMessageTo,
             .createJournal, .markAsRead, .saveJournalEntry,
             .createPark, .editPark:
            .post
        case .getUser, .getFriendsForUser, .getFriendRequests,
             .getAllParks, .getPark,
             .findUsers, .getParksForUser, .getBlacklist,
             .getFutureEvents, .getPastEvents, .getEvent,
             .getDialogs, .getMessages, .getJournals,
             .getJournal, .getJournalEntries,
             .getUpdatedParks, .getCountries:
            .get
        case .declineFriendRequest, .deleteFriend, .deleteFromBlacklist,
             .deleteParkComment, .deleteTrainHere,
             .deleteUser, .deleteGoToEvent,
             .deleteEventComment, .deleteEvent,
             .deleteDialog, .deleteJournal,
             .deleteEntry, .deletePark,
             .deleteEventPhoto, .deleteParkPhoto:
            .delete
        case .editJournalSettings, .editEntry:
            .put
        }
    }

    var hasMultipartFormData: Bool {
        switch self {
        case .createPark, .editPark, .createEvent, .editEvent, .editUser: true
        default: false
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .getAllParks: [.init(name: "fields", value: "short")]
        case let .findUsers(name): [.init(name: "name", value: name)]
        default: []
        }
    }

    enum ParameterKey: String {
        case name, fullname, email, password, comment, message, title, description, date, address, latitude, longitude, image
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

    var bodyParts: BodyMaker.Parts? {
        switch self {
        case .login, .getUser, .getFriendsForUser, .getFriendRequests,
             .acceptFriendRequest, .declineFriendRequest, .findUsers,
             .sendFriendRequest, .deleteFriend, .getBlacklist,
             .addToBlacklist, .deleteFromBlacklist,
             .getPark, .deleteParkComment, .getParksForUser,
             .postTrainHere, .deleteTrainHere, .deleteUser,
             .getFutureEvents, .getPastEvents, .getEvent,
             .postGoToEvent, .deleteGoToEvent, .getCountries,
             .deleteEventComment, .deleteEvent, .getDialogs,
             .getMessages, .deleteDialog, .getJournals,
             .getJournal, .getJournalEntries, .deleteEntry,
             .deleteJournal, .getAllParks,
             .getUpdatedParks, .deletePark,
             .deleteEventPhoto, .deleteParkPhoto:
            return nil
        case let .registration(form):
            return .init([
                ParameterKey.name.rawValue: form.userName,
                ParameterKey.fullname.rawValue: form.fullName,
                ParameterKey.email.rawValue: form.email,
                ParameterKey.password.rawValue: form.password,
                ParameterKey.genderCode.rawValue: form.genderCode.description,
                ParameterKey.countryID.rawValue: form.country.id,
                ParameterKey.cityID.rawValue: form.city.id,
                ParameterKey.birthDate.rawValue: form.birthDateIsoString
            ], nil)
        case let .editUser(_, form):
            let parameters = [
                ParameterKey.name.rawValue: form.userName,
                ParameterKey.fullname.rawValue: form.fullName,
                ParameterKey.email.rawValue: form.email,
                ParameterKey.genderCode.rawValue: form.genderCode.description,
                ParameterKey.countryID.rawValue: form.country.id,
                ParameterKey.cityID.rawValue: form.city.id,
                ParameterKey.birthDate.rawValue: form.birthDateIsoString
            ]
            let mediaFiles: [BodyMaker.MediaFile]? = if let image = form.image {
                [
                    BodyMaker.MediaFile(
                        key: ParameterKey.image.rawValue,
                        filename: "\(UUID().uuidString).jpg",
                        data: image.data,
                        mimeType: image.mimeType
                    )
                ]
            } else {
                nil
            }
            return .init(parameters, mediaFiles)
        case let .resetPassword(login):
            return .init([ParameterKey.usernameOrEmail.rawValue: login], nil)
        case let .changePassword(current, new):
            return .init([
                ParameterKey.password.rawValue: current,
                ParameterKey.newPassword.rawValue: new
            ], nil)
        case let .addCommentToPark(_, comment),
             let .addCommentToEvent(_, comment),
             let .editParkComment(_, _, comment),
             let .editEventComment(_, _, comment):
            return .init([ParameterKey.comment.rawValue: comment], nil)
        case let .sendMessageTo(message, _):
            return .init([ParameterKey.message.rawValue: message], nil)
        case let .markAsRead(userID):
            return .init([ParameterKey.fromUserID.rawValue: userID.description], nil)
        case let .createJournal(_, title):
            return .init([ParameterKey.title.rawValue: title], nil)
        case let .saveJournalEntry(_, _, message),
             let .editEntry(_, _, _, message):
            return .init([ParameterKey.message.rawValue: message], nil)
        case let .editJournalSettings(_, _, title, viewAccess, commentAccess):
            return .init(
                [
                    ParameterKey.title.rawValue: title,
                    ParameterKey.viewAccess.rawValue: viewAccess.description,
                    ParameterKey.commentAccess.rawValue: commentAccess.description
                ],
                nil
            )
        case let .createEvent(form), let .editEvent(_, form):
            let parameters = [
                ParameterKey.title.rawValue: form.title,
                ParameterKey.description.rawValue: form.description,
                ParameterKey.date.rawValue: form.dateIsoString,
                ParameterKey.areaID.rawValue: form.parkID.description
            ]
            let mediaFiles: [BodyMaker.MediaFile]? = form.newMediaFiles.isEmpty
                ? nil
                : form.newMediaFiles.map {
                    BodyMaker.MediaFile(
                        key: $0.key,
                        filename: $0.filename,
                        data: $0.data,
                        mimeType: $0.mimeType
                    )
                }
            return .init(parameters, mediaFiles)
        case let .createPark(form), let .editPark(_, form):
            let parameters = [
                ParameterKey.address.rawValue: form.address,
                ParameterKey.latitude.rawValue: form.latitude,
                ParameterKey.longitude.rawValue: form.longitude,
                ParameterKey.cityID.rawValue: form.cityID.description,
                ParameterKey.typeID.rawValue: form.typeID.description,
                ParameterKey.classID.rawValue: form.sizeID.description
            ]
            let mediaFiles: [BodyMaker.MediaFile]? = form.newMediaFiles.isEmpty
                ? nil
                : form.newMediaFiles.map {
                    BodyMaker.MediaFile(
                        key: $0.key,
                        filename: $0.filename,
                        data: $0.data,
                        mimeType: $0.mimeType
                    )
                }
            return .init(parameters, mediaFiles)
        }
    }
}
