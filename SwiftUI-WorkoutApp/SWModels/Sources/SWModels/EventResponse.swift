import Foundation
import Utils

/// Модель со всей информацией о мероприятии
public struct EventResponse: Codable, Identifiable {
    public let id: Int
    /// Название мероприятия
    public var title: String?
    public var eventDescription: String?
    public let fullAddress, createDate, modifyDate: String?
    public var beginDate: String?
    public var countryID, cityID: Int?
    public let commentsCount: Int?
    public var commentsOptional: [CommentResponse]?
    public let previewImageStringURL: String?
    public var sportsGroundID: Int?
    public let latitude, longitude: String?
    /// Количество участников
    public let participantsCount: Int?
    public var participantsOptional: [UserResponse]?
    /// `true` - предстоящее мероприятие, `false` - прошедшее
    public let isCurrent: Bool?
    public var photosOptional: [Photo]?
    /// Логин автора мероприятия
    public let authorName: String?
    public let author: UserResponse?
    /// Участвует ли пользователь в мероприятии
    ///
    /// Сервер присылает `false`, если хотя бы раз успешно вызвать `deleteGoToEvent`,
    /// поэтому при итоговом определении статуса `trainHere` смотрим на список участников
    public var trainHereOptional: Bool?

    public enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, author
        case authorName = "name"
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
        case photosOptional = "photos"
        case participantsOptional = "training_users"
        case trainHereOptional = "train_here"
        case commentsOptional = "comments"
    }

    public init(
        id: Int,
        title: String? = nil,
        eventDescription: String? = nil,
        fullAddress: String? = nil,
        createDate: String? = nil,
        modifyDate: String? = nil,
        beginDate: String? = nil,
        countryID: Int? = nil,
        cityID: Int? = nil,
        commentsCount: Int? = nil,
        commentsOptional: [CommentResponse]? = nil,
        previewImageStringURL: String? = nil,
        sportsGroundID: Int? = nil,
        latitude: String? = nil,
        longitude: String? = nil,
        participantsCount: Int? = nil,
        participantsOptional: [UserResponse]? = nil,
        isCurrent: Bool? = nil,
        photosOptional: [Photo]? = nil,
        authorName: String? = nil,
        author: UserResponse? = nil,
        trainHereOptional: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.fullAddress = fullAddress
        self.createDate = createDate
        self.modifyDate = modifyDate
        self.beginDate = beginDate
        self.countryID = countryID
        self.cityID = cityID
        self.commentsCount = commentsCount
        self.commentsOptional = commentsOptional
        self.previewImageStringURL = previewImageStringURL
        self.sportsGroundID = sportsGroundID
        self.latitude = latitude
        self.longitude = longitude
        self.participantsCount = participantsCount
        self.participantsOptional = participantsOptional
        self.isCurrent = isCurrent
        self.photosOptional = photosOptional
        self.authorName = authorName
        self.author = author
        self.trainHereOptional = trainHereOptional
    }
}

extension EventResponse: Equatable {
    public static func == (lhs: EventResponse, rhs: EventResponse) -> Bool {
        lhs.id == rhs.id
    }
}

public extension EventResponse {
    var formattedTitle: String {
        get {
            guard let title else { return "" }
            return title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .capitalizingFirstLetter
        }
        set { title = newValue }
    }

    var shortAddress: String {
        if let countryID, let cityID {
            ShortAddressService(countryID, cityID).address
        } else {
            "Не указан"
        }
    }

    var cityName: String? {
        if let countryID, let cityID {
            return ShortAddressService(countryID, cityID).cityName
        }
        return nil
    }

    var hasDescription: Bool {
        !formattedDescription.isEmpty
    }

    var formattedDescription: String {
        get {
            (eventDescription ?? "").withoutHTML
        }
        set { eventDescription = newValue }
    }

    var sportsGround: SportsGround {
        get {
            .init(
                id: sportsGroundID ?? 0,
                typeID: 0,
                sizeID: 0,
                address: fullAddress,
                author: author,
                cityID: cityID,
                commentsCount: nil,
                countryID: countryID,
                createDate: nil,
                modifyDate: nil,
                latitude: latitude ?? "",
                longitude: longitude ?? "",
                name: nil,
                photosOptional: nil,
                preview: nil,
                usersTrainHereCount: nil,
                commentsOptional: nil,
                usersTrainHere: nil,
                trainHere: nil
            )
        }
        set {}
    }

    var previewImageURL: URL? {
        previewImageStringURL.queryAllowedURL
    }

    var eventDateString: String {
        DateFormatterService.readableDate(from: beginDate)
    }

    var hasComments: Bool { !comments.isEmpty }

    var comments: [CommentResponse] {
        get { commentsOptional ?? [] }
        set { commentsOptional = newValue }
    }

    var hasPhotos: Bool { !photos.isEmpty }

    var photos: [Photo] {
        get { photosOptional ?? [] }
        set { photosOptional = newValue }
    }

    var hasParticipants: Bool { !participants.isEmpty }

    /// Список участников мероприятия
    var participants: [UserResponse] {
        get { participantsOptional ?? [] }
        set { participantsOptional = newValue }
    }

    var participantsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleCount", comment: ""),
            participants.count
        )
    }

    /// Пользователь участвует в этом мероприятии
    var trainHere: Bool {
        get { trainHereOptional ?? false }
        set { trainHereOptional = newValue }
    }

    var authorID: Int {
        author?.userID ?? 0
    }

    /// `true` - сервер прислал всю информацию о площадке, `false` - не всю
    var isFull: Bool {
        participantsCount ?? 0 > 0 && !participants.isEmpty
            || commentsCount ?? 0 > 0 && !comments.isEmpty
    }

    static var emptyValue: EventResponse {
        .init(
            id: 0,
            title: nil,
            eventDescription: nil,
            fullAddress: nil,
            createDate: nil,
            modifyDate: nil,
            beginDate: nil,
            countryID: nil,
            cityID: nil,
            commentsCount: nil,
            commentsOptional: nil,
            previewImageStringURL: nil,
            sportsGroundID: nil,
            latitude: nil,
            longitude: nil,
            participantsCount: nil,
            participantsOptional: nil,
            isCurrent: nil,
            photosOptional: nil,
            authorName: nil,
            author: nil,
            trainHereOptional: nil
        )
    }
}
