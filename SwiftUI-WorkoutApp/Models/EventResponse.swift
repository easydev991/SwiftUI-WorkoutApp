import Foundation

/// Модель со всей информацией о мероприятии
struct EventResponse: Codable, Identifiable {
    let id: Int
    /// Название мероприятия
    var title: String?
    var eventDescription: String?
    let fullAddress, createDate, modifyDate: String?
    var beginDate: String?
    var countryID, cityID: Int?
    let commentsCount: Int?
    var commentsOptional: [Comment]?
    let previewImageStringURL: String?
    var sportsGroundID: Int?
    let latitude, longitude: String?
    /// Количество участников
    let participantsCount: Int?
    var participantsOptional: [UserResponse]?
    /// `true` - предстоящее мероприятие, `false` - прошедшее
    let isCurrent: Bool?
    /// `true` - пользователь является организатором, `false` - не является
    let isOrganizer: Bool?
    let photos: [Photo]?
    /// Логин автора мероприятия
    let name: String?
    let author: UserResponse?
    let canEdit: Bool?
    var trainHereOptional: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, photos, author, name
        case fullAddress = "address"
        case previewImageStringURL = "preview"
        case eventDescription = "description"
        case createDate = "create_date"
        case modifyDate = "modify_date"
        case beginDate = "begin_date"
        case countryID = "country_id"
        case cityID = "city_id"
        case commentsCount = "comment_count"
        case sportsGroundID = "area_id"
        case participantsCount = "user_count"
        case isCurrent = "is_current"
        case participantsOptional = "training_users"
        case isOrganizer = "is_organizer"
        case canEdit = "can_edit"
        case trainHereOptional = "train_here"
        case commentsOptional = "comments"
    }
}

extension EventResponse: Equatable {
    static func == (lhs: EventResponse, rhs: EventResponse) -> Bool {
        lhs.id == rhs.id
    }
}

extension EventResponse {
    var formattedTitle: String {
        get {
            title.valueOrEmpty
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .capitalizingFirstLetter
        }
        set { title = newValue }
    }
    var shortAddress: String {
        if let countryID = countryID, let cityID = cityID {
            return ShortAddressService().addressFor(countryID, cityID)
        } else {
            return "Не указан"
        }
    }
    var hasDescription: Bool {
        !formattedDescription.isEmpty
    }
    var formattedDescription: String {
        get {
            eventDescription.valueOrEmpty
                .withoutHTML
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set { eventDescription = newValue }
    }
    var sportsGround: SportsGround {
        get {
            .init(id: sportsGroundID.valueOrZero, typeID: .zero, sizeID: .zero, address: fullAddress, author: author, canEdit: false, mine: false, cityID: cityID, commentsCount: nil, countryID: countryID, createDate: nil, modifyDate: nil, equipmentIDS: nil, latitude: latitude.valueOrEmpty, longitude: longitude.valueOrEmpty, name: nil, photos: nil, preview: nil, usersTrainHereCount: nil, commentsOptional: nil, usersTrainHere: nil, trainHere: nil)
        }
        set {}
    }
    var previewImageURL: URL? {
        .init(string: previewImageStringURL.valueOrEmpty)
    }
    var eventDateString: String {
        FormatterService.readableDate(from: beginDate)
    }
    var comments: [Comment] {
        get { commentsOptional ?? [] }
        set { commentsOptional = newValue }
    }
    var participants: [UserResponse] {
        get { participantsOptional ?? [] }
        set { participantsOptional = newValue }
    }
    /// Пользователь тренируется на этой площадке
    var trainHere: Bool {
        get { trainHereOptional.isTrue }
        set { trainHereOptional = newValue }
    }
    var authorID: Int {
        (author?.userID).valueOrZero
    }
    /// `true` - сервер прислал всю информацию о площадке, `false` - не всю
    var isFull: Bool {
        participantsCount.valueOrZero > .zero && !participants.isEmpty
        || commentsCount.valueOrZero > .zero && !comments.isEmpty
    }
    static var emptyValue: EventResponse {
        .init(id: .zero, title: nil, eventDescription: nil, fullAddress: nil, createDate: nil, modifyDate: nil, beginDate: nil, countryID: nil, cityID: nil, commentsCount: nil, commentsOptional: nil, previewImageStringURL: nil, sportsGroundID: nil, latitude: nil, longitude: nil, participantsCount: nil, participantsOptional: nil, isCurrent: nil, isOrganizer: nil, photos: nil, name: nil, author: nil, canEdit: nil, trainHereOptional: nil)
    }
    static var mock: EventResponse {
        Bundle.main.decodeJson(
            [EventResponse].self,
            fileName: "oldEvents.json"
        ).first!
    }
}
